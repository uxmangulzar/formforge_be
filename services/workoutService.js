const { Op, QueryTypes } = require('sequelize');
const { sequelize } = require('../database/db');
const WorkoutSession = require('../models/workoutSessionModel');
const Exercise = require('../models/exerciseModel');
const ExerciseCategory = require('../models/exerciseCategoryModel');
const Profile = require('../models/profileModel');
const Challenge = require('../models/challengeModel');
const streakService = require('./streakService');

const exerciseInclude = {
    model: Exercise,
    as: 'exercise',
    attributes: [
        'id', 'name', 'type', 'difficulty', 'description',
        'demo_url', 'gif_url', 'target_muscles'
    ],
    include: [{
        model: ExerciseCategory,
        as: 'exerciseCategory',
        attributes: ['slug', 'display_name'],
        required: false
    }]
};

const normalizeMistakes = (raw) => {
    if (raw == null) return null;
    if (Array.isArray(raw)) return raw;
    if (typeof raw === 'string') {
        try {
            const p = JSON.parse(raw);
            return Array.isArray(p) ? p : [p];
        } catch {
            return [raw];
        }
    }
    return [raw];
};

const normalizeFormScore = (raw) => {
    if (raw == null || raw === '') return null;
    const n = parseInt(raw, 10);
    if (!Number.isFinite(n)) return null;
    return Math.min(100, Math.max(0, n));
};

const validateCreatePayload = async (body) => {
    const exercise_id = body.exercise_id != null ? String(body.exercise_id).trim() : '';
    if (!exercise_id) {
        throw new Error('exercise_id is required');
    }

    const exercise = await Exercise.findOne({ where: { id: exercise_id, is_active: true } });
    if (!exercise) {
        throw new Error('Exercise not found or inactive');
    }

    const mode = body.mode != null ? String(body.mode).trim() : exercise.type;
    if (!['train', 'play', 'recover'].includes(mode)) {
        throw new Error('mode must be train, play, or recover');
    }

    let challenge_id = null;
    if (body.challenge_id != null && String(body.challenge_id).trim()) {
        challenge_id = String(body.challenge_id).trim();
        const ch = await Challenge.findByPk(challenge_id);
        if (!ch) {
            throw new Error('challenge_id not found');
        }
    }

    const completedAtRaw = body.completed_at || body.completedAt;
    const completed_at = completedAtRaw ? new Date(completedAtRaw) : new Date();
    if (Number.isNaN(completed_at.getTime())) {
        throw new Error('Invalid completed_at');
    }

    return {
        exercise_id,
        mode,
        challenge_id,
        form_score: normalizeFormScore(body.form_score),
        reps: Math.max(0, parseInt(body.reps, 10) || 0),
        sets: Math.max(0, parseInt(body.sets, 10) || 0),
        duration_sec: Math.max(0, parseInt(body.duration_sec, 10) || 0),
        calories: body.calories != null ? Math.max(0, parseInt(body.calories, 10) || 0) : null,
        xp_earned: Math.max(0, parseInt(body.xp_earned, 10) || 0),
        mistakes: normalizeMistakes(body.mistakes),
        notes: body.notes != null ? String(body.notes).trim().slice(0, 2000) : null,
        completed_at
    };
};

const formatSession = (row) => {
    const j = row.toJSON ? row.toJSON() : row;
    return j;
};

const createWorkoutSession = async (userId, body, options = {}) => {
    const data = await validateCreatePayload(body);
    const timeZone = streakService.resolveTimeZone(options.timeZone);

    const t = await sequelize.transaction();
    try {
        const session = await WorkoutSession.create({
            user_id: userId,
            ...data
        }, { transaction: t });

        if (data.xp_earned > 0) {
            const profile = await Profile.findOne({ where: { user_id: userId }, transaction: t });
            if (profile) {
                await profile.increment('total_xp', { by: data.xp_earned, transaction: t });
            }
        }

        const streak = await streakService.updateWorkoutStreak(userId, data.completed_at, {
            transaction: t,
            timeZone
        });

        await t.commit();

        const sessionRow = await WorkoutSession.findByPk(session.id, { include: [exerciseInclude] });
        return { session: sessionRow, streak };
    } catch (err) {
        await t.rollback();
        throw err;
    }
};

const listWorkoutSessions = async (userId, filters = {}) => {
    const limit = Math.min(Math.max(Number(filters.limit) || 10, 1), 50);
    const page = Math.max(Number(filters.page) || 1, 1);
    const offset = (page - 1) * limit;

    const where = { user_id: userId };

    if (filters.exercise_id) {
        where.exercise_id = String(filters.exercise_id).trim();
    }
    if (filters.mode && ['train', 'play', 'recover'].includes(filters.mode)) {
        where.mode = filters.mode;
    }
    if (filters.challenge_id) {
        where.challenge_id = String(filters.challenge_id).trim();
    }
    if (filters.from || filters.to) {
        where.completed_at = {};
        if (filters.from) {
            const from = new Date(filters.from);
            if (!Number.isNaN(from.getTime())) where.completed_at[Op.gte] = from;
        }
        if (filters.to) {
            const to = new Date(filters.to);
            if (!Number.isNaN(to.getTime())) where.completed_at[Op.lte] = to;
        }
        if (!Object.keys(where.completed_at).length) delete where.completed_at;
    }

    const { count, rows } = await WorkoutSession.findAndCountAll({
        where,
        include: [exerciseInclude],
        order: [['completed_at', 'DESC']],
        limit,
        offset
    });

    const totalPages = Math.max(Math.ceil(count / limit), 1);

    return {
        data: rows.map(formatSession),
        pagination: {
            page,
            limit,
            total: count,
            totalPages,
            hasPrev: page > 1,
            hasNext: page < totalPages
        }
    };
};

const getWorkoutSessionById = async (userId, sessionId) => {
    const row = await WorkoutSession.findOne({
        where: { id: sessionId, user_id: userId },
        include: [exerciseInclude]
    });
    return row;
};

const getWorkoutStats = async (userId, filters = {}) => {
    const where = { user_id: userId };
    if (filters.exercise_id) {
        where.exercise_id = String(filters.exercise_id).trim();
    }
    if (filters.mode && ['train', 'play', 'recover'].includes(filters.mode)) {
        where.mode = filters.mode;
    }

    const total_sessions = await WorkoutSession.count({ where });

    const bestScoreRow = await WorkoutSession.findOne({
        where: { ...where, form_score: { [Op.not]: null } },
        order: [['form_score', 'DESC']],
        attributes: ['form_score', 'exercise_id', 'completed_at']
    });

    const totals = await WorkoutSession.findOne({
        where,
        attributes: [
            [sequelize.fn('SUM', sequelize.col('reps')), 'total_reps'],
            [sequelize.fn('SUM', sequelize.col('duration_sec')), 'total_duration_sec'],
            [sequelize.fn('SUM', sequelize.col('calories')), 'total_calories'],
            [sequelize.fn('SUM', sequelize.col('xp_earned')), 'total_xp_earned']
        ],
        raw: true
    });

    const recent = await WorkoutSession.findAll({
        where,
        include: [exerciseInclude],
        order: [['completed_at', 'DESC']],
        limit: 5
    });

    let exercise_breakdown = [];
    if (!filters.exercise_id) {
        exercise_breakdown = await sequelize.query(
            `SELECT ws.exercise_id,
                    e.name AS exercise_name,
                    COUNT(*) AS session_count,
                    MAX(ws.form_score) AS best_form_score,
                    AVG(ws.form_score) AS avg_form_score
             FROM workout_sessions ws
             INNER JOIN exercises e ON e.id = ws.exercise_id
             WHERE ws.user_id = :userId
             ${filters.mode ? 'AND ws.mode = :mode' : ''}
             GROUP BY ws.exercise_id, e.name
             ORDER BY session_count DESC
             LIMIT 20`,
            {
                replacements: { userId, mode: filters.mode },
                type: QueryTypes.SELECT
            }
        );
    }

    return {
        total_sessions,
        best_form_score: bestScoreRow ? bestScoreRow.form_score : null,
        best_form_score_at: bestScoreRow ? bestScoreRow.completed_at : null,
        total_reps: Number(totals?.total_reps) || 0,
        total_duration_sec: Number(totals?.total_duration_sec) || 0,
        total_calories: Number(totals?.total_calories) || 0,
        total_xp_earned: Number(totals?.total_xp_earned) || 0,
        recent_sessions: recent.map(formatSession),
        exercise_breakdown: exercise_breakdown.map((r) => ({
            exercise_id: r.exercise_id,
            exercise_name: r.exercise_name,
            session_count: Number(r.session_count) || 0,
            best_form_score: r.best_form_score != null ? Number(r.best_form_score) : null,
            avg_form_score: r.avg_form_score != null ? Math.round(Number(r.avg_form_score)) : null
        }))
    };
};

module.exports = {
    createWorkoutSession,
    listWorkoutSessions,
    getWorkoutSessionById,
    getWorkoutStats
};
