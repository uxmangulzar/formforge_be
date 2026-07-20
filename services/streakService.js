const { Op } = require('sequelize');
const { sequelize } = require('../database/db');
const Profile = require('../models/profileModel');
const WorkoutSession = require('../models/workoutSessionModel');

const DEFAULT_TIME_ZONE = 'UTC';

const resolveTimeZone = (input) => {
    const tz = input != null ? String(input).trim() : '';
    if (!tz) return DEFAULT_TIME_ZONE;
    try {
        Intl.DateTimeFormat(undefined, { timeZone: tz });
        return tz;
    } catch {
        return DEFAULT_TIME_ZONE;
    }
};

const toDateKey = (date, timeZone = DEFAULT_TIME_ZONE) => {
    const d = date instanceof Date ? date : new Date(date);
    if (Number.isNaN(d.getTime())) return null;
    return new Intl.DateTimeFormat('en-CA', {
        timeZone,
        year: 'numeric',
        month: '2-digit',
        day: '2-digit'
    }).format(d);
};

const shiftDateKey = (dateKey, deltaDays) => {
    const [y, m, d] = dateKey.split('-').map(Number);
    const dt = new Date(Date.UTC(y, m - 1, d));
    dt.setUTCDate(dt.getUTCDate() + deltaDays);
    return dt.toISOString().slice(0, 10);
};

const formatStreakPayload = (profile, { timeZone, workoutsToday = 0, streakIncreased = false } = {}) => {
    const todayKey = toDateKey(new Date(), timeZone);
    const lastKey = profile.last_streak_date
        ? (typeof profile.last_streak_date === 'string'
            ? profile.last_streak_date.slice(0, 10)
            : toDateKey(profile.last_streak_date, timeZone))
        : null;

    const streakActiveToday = lastKey === todayKey;

    return {
        current_streak: profile.current_streak || 0,
        longest_streak: profile.longest_streak || 0,
        last_activity_date: lastKey,
        streak_active_today: streakActiveToday,
        workouts_today: workoutsToday,
        streak_increased: streakIncreased,
        timezone: timeZone
    };
};

const countWorkoutsOnDate = async (userId, dateKey, timeZone, transaction) => {
    const rangeStart = new Date(`${shiftDateKey(dateKey, -1)}T12:00:00.000Z`);
    const rangeEnd = new Date(`${shiftDateKey(dateKey, 2)}T12:00:00.000Z`);

    const rows = await WorkoutSession.findAll({
        where: {
            user_id: userId,
            completed_at: { [Op.gte]: rangeStart, [Op.lt]: rangeEnd }
        },
        attributes: ['completed_at'],
        transaction
    });

    return rows.filter((row) => toDateKey(row.completed_at, timeZone) === dateKey).length;
};

/**
 * Call when a workout is logged. Updates current_streak / longest_streak / last_streak_date.
 */
const updateWorkoutStreak = async (userId, activityDate, { transaction, timeZone } = {}) => {
    const tz = resolveTimeZone(timeZone);
    const activityKey = toDateKey(activityDate, tz);
    if (!activityKey) {
        throw new Error('Invalid activity date for streak update');
    }

    const profile = await Profile.findOne({ where: { user_id: userId }, transaction });
    if (!profile) {
        throw new Error('Profile not found');
    }

    const lastKey = profile.last_streak_date
        ? String(profile.last_streak_date).slice(0, 10)
        : null;

    let streakIncreased = false;
    let nextStreak = profile.current_streak || 0;

    if (lastKey === activityKey) {
        streakIncreased = false;
    } else if (!lastKey) {
        nextStreak = 1;
        streakIncreased = true;
    } else if (lastKey === shiftDateKey(activityKey, -1)) {
        nextStreak = (profile.current_streak || 0) + 1;
        streakIncreased = true;
    } else {
        nextStreak = 1;
        streakIncreased = true;
    }

    const nextLongest = Math.max(profile.longest_streak || 0, nextStreak);

    if (lastKey !== activityKey) {
        await profile.update({
            current_streak: nextStreak,
            longest_streak: nextLongest,
            last_streak_date: activityKey
        }, { transaction });
    } else if (nextLongest > (profile.longest_streak || 0)) {
        await profile.update({ longest_streak: nextLongest }, { transaction });
    }

    await profile.reload({ transaction });

    const workoutsToday = await countWorkoutsOnDate(userId, activityKey, tz, transaction);

    return formatStreakPayload(profile, {
        timeZone: tz,
        workoutsToday,
        streakIncreased
    });
};

const getStreakSummary = async (userId, { timeZone } = {}) => {
    const tz = resolveTimeZone(timeZone);
    const profile = await Profile.findOne({ where: { user_id: userId } });
    if (!profile) {
        throw new Error('Profile not found');
    }

    const todayKey = toDateKey(new Date(), tz);
    const workoutsToday = await countWorkoutsOnDate(userId, todayKey, tz);

    const lastKey = profile.last_streak_date
        ? String(profile.last_streak_date).slice(0, 10)
        : null;

    let currentStreak = profile.current_streak || 0;
    if (lastKey && lastKey !== todayKey && lastKey !== shiftDateKey(todayKey, -1)) {
        currentStreak = 0;
    }

    return formatStreakPayload(
        { ...profile.toJSON(), current_streak: currentStreak },
        { timeZone: tz, workoutsToday, streakIncreased: false }
    );
};

const getStreakCalendar = async (userId, { year, month, timeZone } = {}) => {
    const tz = resolveTimeZone(timeZone);
    const y = parseInt(year, 10) || new Date().getFullYear();
    const m = parseInt(month, 10) || new Date().getMonth() + 1;
    if (m < 1 || m > 12) {
        throw new Error('month must be between 1 and 12');
    }

    const monthStartKey = `${y}-${String(m).padStart(2, '0')}-01`;
    const lastDay = new Date(Date.UTC(y, m, 0)).getUTCDate();
    const monthEndKey = `${y}-${String(m).padStart(2, '0')}-${String(lastDay).padStart(2, '0')}`;

    const rangeStart = new Date(`${shiftDateKey(monthStartKey, -1)}T00:00:00.000Z`);
    const rangeEnd = new Date(`${shiftDateKey(monthEndKey, 1)}T23:59:59.999Z`);

    const rows = await WorkoutSession.findAll({
        where: {
            user_id: userId,
            completed_at: { [Op.between]: [rangeStart, rangeEnd] }
        },
        attributes: ['id', 'completed_at', 'mode', 'form_score'],
        order: [['completed_at', 'ASC']]
    });

    const dayMap = new Map();
    for (const row of rows) {
        const key = toDateKey(row.completed_at, tz);
        if (!key || key < monthStartKey || key > monthEndKey) continue;

        if (!dayMap.has(key)) {
            dayMap.set(key, {
                date: key,
                workout_count: 0,
                modes: new Set(),
                best_form_score: null
            });
        }
        const entry = dayMap.get(key);
        entry.workout_count += 1;
        entry.modes.add(row.mode);
        if (row.form_score != null) {
            entry.best_form_score =
                entry.best_form_score == null
                    ? row.form_score
                    : Math.max(entry.best_form_score, row.form_score);
        }
    }

    const days = [...dayMap.values()]
        .map((d) => ({
            date: d.date,
            workout_count: d.workout_count,
            modes: [...d.modes],
            best_form_score: d.best_form_score,
            streak_day: true
        }))
        .sort((a, b) => a.date.localeCompare(b.date));

    return {
        year: y,
        month: m,
        timezone: tz,
        active_days: days.length,
        days
    };
};

module.exports = {
    resolveTimeZone,
    updateWorkoutStreak,
    getStreakSummary,
    getStreakCalendar
};
