const { Op } = require('sequelize');
const { sequelize } = require('../database/db');
const Challenge = require('../models/challengeModel');
const ChallengeStage = require('../models/challengeStageModel');
const ChallengeStageExercise = require('../models/challengeStageExerciseModel');
const Exercise = require('../models/exerciseModel');
const ExerciseCategory = require('../models/exerciseCategoryModel');
const Badge = require('../models/badgeModel');
const BadgeRule = require('../models/badgeRuleModel');
const UserChallenge = require('../models/userChallengeModel');
const UserChallengeStageProgress = require('../models/userChallengeStageProgressModel');
const UserChallengeExerciseProgress = require('../models/userChallengeExerciseProgressModel');
const UserBadge = require('../models/userBadgeModel');
const Profile = require('../models/profileModel');
const User = require('../models/userModel');

const exerciseInclude = {
    model: Exercise,
    as: 'exercise',
    attributes: [
        'id', 'name', 'type', 'difficulty', 'description',
        'demo_url', 'gif_url', 'data_url', 'target_muscles',
        'logic_config', 'rep_counting_logic'
    ],
    include: [{
        model: ExerciseCategory,
        as: 'exerciseCategory',
        attributes: ['slug', 'display_name'],
        required: false
    }]
};

const publicChallengeDetailInclude = (challengePk) => [{
    model: ChallengeStage,
    as: 'stages',
    include: [{
        model: ChallengeStageExercise,
        as: 'stageExercises',
        include: [exerciseInclude]
    }]
}, {
    model: Badge,
    as: 'challengeBadges',
    where: { challenge_id: challengePk, is_active: true },
    required: false,
    include: [{
        model: BadgeRule,
        as: 'rules',
        where: { challenge_id: challengePk, is_active: true },
        required: false
    }]
}];

const findPublishedChallenge = async (id) => {
    const row = await Challenge.findOne({
        where: { id, status: 'published' },
        include: publicChallengeDetailInclude(id),
        order: [[{ model: ChallengeStage, as: 'stages' }, 'stage_order', 'ASC']]
    });
    return row;
};

const mapChallengeListItem = (row, joinedMap = null) => {
    const j = row.toJSON ? row.toJSON() : row;
    const stageCount = Array.isArray(j.stages) ? j.stages.length : 0;
    delete j.stages;

    const userEnrollment = joinedMap ? joinedMap.get(j.id) : null;
    const is_joined = !!userEnrollment;

    return {
        ...j,
        stage_count: stageCount,
        participant_count: Number(j.participant_count) || 0,
        is_joined,
        user_joined_at: userEnrollment ? userEnrollment.joined_at : null
    };
};

const listPublicChallenges = async (filters = {}, userId = null) => {
    const limit = Math.min(Math.max(Number(filters.limit) || 10, 1), 50);
    const page = Math.max(Number(filters.page) || 1, 1);
    const offset = (page - 1) * limit;
    const now = new Date();

    const where = { status: 'published' };
    if (filters.active === 'true' || filters.active === true) {
        where.starts_at = { [Op.lte]: now };
        where.ends_at = { [Op.gt]: now };
    }

    const { count, rows } = await Challenge.findAndCountAll({
        where,
        attributes: {
            include: [[
                sequelize.literal(
                    '(SELECT COUNT(*) FROM user_challenges uc WHERE uc.challenge_id = `Challenge`.`id`)'
                ),
                'participant_count'
            ]]
        },
        include: [{
            model: ChallengeStage,
            as: 'stages',
            attributes: ['id'],
            required: false
        }],
        order: [['starts_at', 'DESC']],
        limit,
        offset,
        distinct: true
    });

    let joinedMap = null;
    if (userId && rows.length) {
        const challengeIds = rows.map(r => r.id);
        const userEnrollments = await UserChallenge.findAll({
            where: {
                user_id: userId,
                challenge_id: { [Op.in]: challengeIds }
            },
            attributes: ['challenge_id', 'status', 'joined_at']
        });
        joinedMap = new Map(userEnrollments.map(ue => [ue.challenge_id, ue]));
    }

    const totalPages = Math.max(Math.ceil(count / limit), 1);

    return {
        data: rows.map(row => mapChallengeListItem(row, joinedMap)),
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

const getUserLeaderboardRank = async (challengeId, totalPointsEarned, joinedAt) => {
    const higherRankCount = await UserChallenge.count({
        where: {
            challenge_id: challengeId,
            [Op.or]: [
                { total_points_earned: { [Op.gt]: totalPointsEarned } },
                {
                    total_points_earned: totalPointsEarned,
                    joined_at: { [Op.lt]: joinedAt }
                }
            ]
        }
    });
    return higherRankCount + 1;
};

const getTopLeaderboardForChallenge = async (challengeId, limit = 5) => {
    const rows = await UserChallenge.findAll({
        where: { challenge_id: challengeId },
        attributes: ['id', 'user_id', 'total_points_earned', 'joined_at'],
        include: [{
            model: User,
            as: 'user',
            attributes: ['id'],
            include: [{
                model: Profile,
                as: 'profile',
                attributes: ['full_name', 'avatar_url']
            }]
        }],
        order: [['total_points_earned', 'DESC'], ['joined_at', 'ASC']],
        limit
    });

    return rows.map((uc, index) => {
        const j = uc.toJSON();
        const profile = j.user ? j.user.profile : null;
        return {
            rank: index + 1,
            user_id: j.user_id,
            full_name: profile ? profile.full_name : 'Athlete',
            avatar_url: profile ? profile.avatar_url : null,
            total_points_earned: j.total_points_earned || 0
        };
    });
};

const syncUserChallengeStageProgress = async (userChallengeId, challengeId, transaction = null) => {
    const opts = transaction ? { transaction } : {};

    const currentStages = await ChallengeStage.findAll({
        where: { challenge_id: challengeId },
        order: [['stage_order', 'ASC']],
        include: [{ model: ChallengeStageExercise, as: 'stageExercises' }],
        ...opts
    });

    if (!currentStages.length) return;

    const currentStageIds = new Set(currentStages.map((s) => s.id));
    const currentCseIds = new Set(
        currentStages.flatMap((s) => (s.stageExercises || []).map((se) => se.id))
    );

    const existingStageProgs = await UserChallengeStageProgress.findAll({
        where: { user_challenge_id: userChallengeId },
        ...opts
    });

    const staleStageProgIds = existingStageProgs
        .filter((sp) => !currentStageIds.has(sp.challenge_stage_id))
        .map((sp) => sp.id);

    if (staleStageProgIds.length) {
        await UserChallengeStageProgress.destroy({
            where: { id: { [Op.in]: staleStageProgIds } },
            ...opts
        });
    }

    const existingEpList = await UserChallengeExerciseProgress.findAll({
        where: { user_challenge_id: userChallengeId },
        ...opts
    });

    const staleEpIds = existingEpList
        .filter((ep) => !currentCseIds.has(ep.challenge_stage_exercise_id))
        .map((ep) => ep.id);

    if (staleEpIds.length) {
        await UserChallengeExerciseProgress.destroy({
            where: { id: { [Op.in]: staleEpIds } },
            ...opts
        });
    }

    const validStageProgs = await UserChallengeStageProgress.findAll({
        where: { user_challenge_id: userChallengeId },
        ...opts
    });

    const stageMap = new Map(validStageProgs.map((sp) => [sp.challenge_stage_id, sp]));
    const hasActiveOrCompleted = validStageProgs.some((sp) =>
        ['active', 'in_progress', 'completed'].includes(sp.status)
    );

    let setFirstAsActive = !hasActiveOrCompleted;

    for (let i = 0; i < currentStages.length; i += 1) {
        const stage = currentStages[i];
        let sp = stageMap.get(stage.id);

        if (!sp) {
            const initialStatus = setFirstAsActive ? 'active' : 'locked';
            if (setFirstAsActive) setFirstAsActive = false;

            sp = await UserChallengeStageProgress.create({
                user_challenge_id: userChallengeId,
                challenge_stage_id: stage.id,
                status: initialStatus
            }, opts);
            stageMap.set(stage.id, sp);
        }

        const validEps = await UserChallengeExerciseProgress.findAll({
            where: { user_challenge_id: userChallengeId },
            ...opts
        });
        const epMap = new Map(validEps.map((ep) => [ep.challenge_stage_exercise_id, ep]));

        const stageExercises = stage.stageExercises || [];
        for (const se of stageExercises) {
            if (!epMap.has(se.id)) {
                await UserChallengeExerciseProgress.create({
                    user_challenge_id: userChallengeId,
                    challenge_stage_exercise_id: se.id,
                    sets_completed: 0,
                    reps_logged: 0,
                    status: 'not_started',
                    points_awarded: 0
                }, opts);
            }
        }
    }
};

const getPublicChallengeById = async (id, userId = null) => {
    const row = await findPublishedChallenge(id);
    if (!row) return null;

    const j = row.toJSON();
    const participant_count = await UserChallenge.count({ where: { challenge_id: id } });
    const top_leaderboard = await getTopLeaderboardForChallenge(id, 5);

    let is_joined = false;
    let userChallenge = null;

    if (userId) {
        userChallenge = await UserChallenge.findOne({
            where: { user_id: userId, challenge_id: id }
        });
        if (userChallenge) {
            is_joined = true;
            await syncUserChallengeStageProgress(userChallenge.id, id);
        }
    }

    // IF USER HAS NOT JOINED: DO NOT RETURN ANY EXERCISES OR STAGES
    if (!is_joined || !userChallenge) {
        delete j.stages;
        return {
            ...j,
            participant_count,
            is_joined: false,
            user_joined_at: null,
            leaderboard_rank: null,
            top_leaderboard,
            stages: []
        };
    }

    // IF USER HAS JOINED: CALCULATE LEADERBOARD RANK & ACTIVE DAY EXERCISES
    const leaderboard_rank = await getUserLeaderboardRank(
        id,
        userChallenge.total_points_earned || 0,
        userChallenge.joined_at
    );

    const stageProgressList = await UserChallengeStageProgress.findAll({
        where: { user_challenge_id: userChallenge.id },
        include: [{
            model: ChallengeStage,
            as: 'challengeStage',
            attributes: ['id', 'stage_order', 'title', 'description', 'points_bonus']
        }],
        order: [[{ model: ChallengeStage, as: 'challengeStage' }, 'stage_order', 'ASC']]
    });

    let activeProgress = stageProgressList.find(sp => sp.status === 'active' || sp.status === 'in_progress');
    if (!activeProgress) {
        activeProgress = stageProgressList.find(sp => sp.status === 'locked') || stageProgressList[stageProgressList.length - 1];
    }

    let activeDayStageId = activeProgress ? activeProgress.challenge_stage_id : null;
    let activeDayOrder = activeProgress && activeProgress.challengeStage ? activeProgress.challengeStage.stage_order : 1;
    let activeDayTitle = activeProgress && activeProgress.challengeStage ? activeProgress.challengeStage.title : `Day ${activeDayOrder}`;
    let activeDayDesc = activeProgress && activeProgress.challengeStage ? activeProgress.challengeStage.description : '';
    let activeDayBonus = activeProgress && activeProgress.challengeStage ? activeProgress.challengeStage.points_bonus : 0;

    let current_day_exercises = [];
    if (activeDayStageId) {
        const cses = await ChallengeStageExercise.findAll({
            where: { challenge_stage_id: activeDayStageId },
            include: [exerciseInclude],
            order: [['sequence_order', 'ASC']]
        });

        const exerciseProgressList = await UserChallengeExerciseProgress.findAll({
            where: { user_challenge_id: userChallenge.id }
        });
        const epMap = new Map(exerciseProgressList.map(ep => [ep.challenge_stage_exercise_id, ep]));

        current_day_exercises = cses.map(cse => {
            const rawCse = cse.toJSON();
            const userEp = epMap.get(cse.id);
            return {
                ...rawCse,
                user_progress: userEp ? {
                    status: userEp.status,
                    sets_completed: userEp.sets_completed,
                    reps_logged: userEp.reps_logged,
                    points_awarded: userEp.points_awarded,
                    form_score: userEp.form_score,
                    mistakes_detected: userEp.mistakes_detected
                } : {
                    status: 'not_started',
                    sets_completed: 0,
                    reps_logged: 0,
                    points_awarded: 0
                }
            };
        });
    }

    delete j.stages;

    return {
        ...j,
        participant_count,
        is_joined: true,
        user_joined_at: userChallenge.joined_at,
        leaderboard_rank,
        top_leaderboard,
        user_status: userChallenge.status,
        total_points_earned: userChallenge.total_points_earned || 0,
        current_day: activeDayOrder,
        current_day_title: activeDayTitle,
        current_day_description: activeDayDesc,
        current_day_points_bonus: activeDayBonus,
        current_day_exercises
    };
};

const getUserChallengeRow = async (userId, challengeId) =>
    UserChallenge.findOne({ where: { user_id: userId, challenge_id: challengeId } });

const joinChallenge = async (userId, challengeId) => {
    const challenge = await Challenge.findOne({ where: { id: challengeId, status: 'published' } });
    if (!challenge) {
        throw new Error('Challenge not found or not available');
    }

    const now = new Date();
    if (now >= challenge.ends_at) {
        throw new Error('This challenge has ended');
    }

    const existing = await getUserChallengeRow(userId, challengeId);
    if (existing) {
        throw new Error('You have already joined this challenge');
    }

    const stages = await ChallengeStage.findAll({
        where: { challenge_id: challengeId },
        order: [['stage_order', 'ASC']],
        include: [{ model: ChallengeStageExercise, as: 'stageExercises' }]
    });

    if (!stages.length) {
        throw new Error('Challenge has no stages configured');
    }

    let userChallengeId;
    const t = await sequelize.transaction();
    try {
        const uc = await UserChallenge.create({
            user_id: userId,
            challenge_id: challengeId,
            status: now >= challenge.starts_at ? 'in_progress' : 'joined',
            total_points_earned: 0,
            joined_at: now
        }, { transaction: t });
        userChallengeId = uc.id;

        for (let i = 0; i < stages.length; i += 1) {
            const stage = stages[i];
            const stageStatus = i === 0 ? 'active' : 'locked';
            await UserChallengeStageProgress.create({
                user_challenge_id: uc.id,
                challenge_stage_id: stage.id,
                status: stageStatus
            }, { transaction: t });

            const stageExercises = stage.stageExercises || [];
            for (const se of stageExercises) {
                await UserChallengeExerciseProgress.create({
                    user_challenge_id: uc.id,
                    challenge_stage_exercise_id: se.id,
                    sets_completed: 0,
                    reps_logged: 0,
                    status: 'not_started',
                    points_awarded: 0
                }, { transaction: t });
            }
        }

        await t.commit();
    } catch (err) {
        await t.rollback();
        if (err.name === 'SequelizeUniqueConstraintError') {
            throw new Error('You have already joined this challenge');
        }
        throw err;
    }

    return getMyChallengeProgress(userId, challengeId);
};

const listMyChallenges = async (userId, filters = {}) => {
    const limit = Math.min(Math.max(Number(filters.limit) || 10, 1), 50);
    const page = Math.max(Number(filters.page) || 1, 1);
    const offset = (page - 1) * limit;

    const where = { user_id: userId };
    if (filters.status) {
        where.status = filters.status;
    }

    const { count, rows } = await UserChallenge.findAndCountAll({
        where,
        include: [{
            model: Challenge,
            as: 'challenge',
            attributes: ['id', 'name', 'description', 'starts_at', 'ends_at', 'status', 'image_urls', 'video_urls']
        }],
        order: [['joined_at', 'DESC']],
        limit,
        offset
    });

    const totalPages = Math.max(Math.ceil(count / limit), 1);

    return {
        data: rows,
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

const buildProgressPayload = async (userChallenge) => {
    const uc = userChallenge.toJSON ? userChallenge.toJSON() : userChallenge;
    const stageProgress = await UserChallengeStageProgress.findAll({
        where: { user_challenge_id: uc.id },
        include: [{
            model: ChallengeStage,
            as: 'challengeStage',
            attributes: ['id', 'stage_order', 'title', 'description', 'points_bonus']
        }],
        order: [[{ model: ChallengeStage, as: 'challengeStage' }, 'stage_order', 'ASC']]
    });

    const exerciseProgress = await UserChallengeExerciseProgress.findAll({
        where: { user_challenge_id: uc.id },
        include: [{
            model: ChallengeStageExercise,
            as: 'challengeStageExercise',
            include: [exerciseInclude]
        }]
    });

    return {
        ...uc,
        stageProgress,
        exerciseProgress
    };
};

const getMyChallengeProgress = async (userId, challengeId) => {
    const uc = await UserChallenge.findOne({
        where: { user_id: userId, challenge_id: challengeId },
        include: [{
            model: Challenge,
            as: 'challenge',
            attributes: ['id', 'name', 'description', 'starts_at', 'ends_at', 'status']
        }]
    });
    if (!uc) return null;
    await syncUserChallengeStageProgress(uc.id, challengeId);
    return buildProgressPayload(uc);
};

const allStagesCompleted = async (userChallengeId, challengeId, transaction) => {
    const stages = await ChallengeStage.findAll({
        where: { challenge_id: challengeId },
        attributes: ['id'],
        transaction
    });
    if (!stages.length) return false;

    const completed = await UserChallengeStageProgress.count({
        where: {
            user_challenge_id: userChallengeId,
            challenge_stage_id: { [Op.in]: stages.map((s) => s.id) },
            status: 'completed'
        },
        transaction
    });
    return completed === stages.length;
};

const evaluateAndAwardBadges = async (userId, userChallenge, challengeId, transaction) => {
    const badges = await Badge.findAll({
        where: { challenge_id: challengeId, is_active: true },
        include: [{
            model: BadgeRule,
            as: 'rules',
            where: { challenge_id: challengeId, is_active: true },
            required: false
        }],
        transaction
    });

    if (!badges.length) return [];

    const existing = await UserBadge.findAll({
        where: {
            user_id: userId,
            badge_id: { [Op.in]: badges.map((b) => b.id) }
        },
        transaction
    });
    const earnedIds = new Set(existing.map((e) => e.badge_id));
    const awarded = [];

    for (const badge of badges) {
        if (earnedIds.has(badge.id)) continue;
        const rule = badge.rules && badge.rules[0];
        if (!rule) continue;

        let qualifies = false;
        switch (rule.trigger_type) {
            case 'challenge_complete':
                qualifies = userChallenge.status === 'completed';
                break;
            case 'challenge_all_stages':
                qualifies = await allStagesCompleted(userChallenge.id, challengeId, transaction);
                break;
            case 'points_threshold': {
                const cfg = rule.trigger_config || {};
                const minPts = Number(cfg.min_points) || 0;
                qualifies = userChallenge.total_points_earned >= minPts;
                break;
            }
            default:
                break;
        }

        if (qualifies) {
            await UserBadge.create({
                user_id: userId,
                badge_id: badge.id,
                earned_at: new Date(),
                context: {
                    challenge_id: challengeId,
                    user_challenge_id: userChallenge.id,
                    trigger_type: rule.trigger_type
                }
            }, { transaction });
            awarded.push(badge);
        }
    }

    return awarded;
};

const advanceStagesIfNeeded = async (userChallenge, transaction) => {
    const stages = await ChallengeStage.findAll({
        where: { challenge_id: userChallenge.challenge_id },
        order: [['stage_order', 'ASC']],
        transaction
    });

    for (const stage of stages) {
        const stageProg = await UserChallengeStageProgress.findOne({
            where: {
                user_challenge_id: userChallenge.id,
                challenge_stage_id: stage.id
            },
            transaction
        });
        if (!stageProg || stageProg.status === 'completed') continue;
        if (stageProg.status === 'locked') break;

        const stageExercises = await ChallengeStageExercise.findAll({
            where: { challenge_stage_id: stage.id },
            transaction
        });
        const required = stageExercises.filter((se) => !se.optional);
        const toCheck = required.length ? required : stageExercises;

        let stageDone = true;
        for (const se of toCheck) {
            const ep = await UserChallengeExerciseProgress.findOne({
                where: {
                    user_challenge_id: userChallenge.id,
                    challenge_stage_exercise_id: se.id
                },
                transaction
            });
            if (!ep || ep.status !== 'completed') {
                stageDone = false;
                break;
            }
        }

        if (!stageDone) break;

        await stageProg.update({ status: 'completed', completed_at: new Date() }, { transaction });
        if (stage.points_bonus > 0) {
            await userChallenge.increment('total_points_earned', { by: stage.points_bonus, transaction });
        }

        const idx = stages.findIndex((s) => s.id === stage.id);
        const nextStage = stages[idx + 1];
        if (nextStage) {
            const nextProg = await UserChallengeStageProgress.findOne({
                where: {
                    user_challenge_id: userChallenge.id,
                    challenge_stage_id: nextStage.id
                },
                transaction
            });
            if (nextProg && nextProg.status === 'locked') {
                await nextProg.update({ status: 'active' }, { transaction });
            }
        } else {
            await userChallenge.update({
                status: 'completed',
                completed_at: new Date()
            }, { transaction });
        }
    }

    await userChallenge.reload({ transaction });
};

const normalizeMistakes = (raw) => {
    if (raw == null) return undefined;
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
    if (raw == null || raw === '') return undefined;
    const n = parseInt(raw, 10);
    if (!Number.isFinite(n)) return undefined;
    return Math.min(100, Math.max(0, n));
};

const resolveProgressCounts = (body, ep) => {
    let setsCompleted = ep.sets_completed;
    let repsLogged = ep.reps_logged;

    if (body.increment_sets != null) {
        setsCompleted += Math.max(0, parseInt(body.increment_sets, 10) || 0);
    } else if (body.sets_completed != null) {
        setsCompleted = Math.max(0, parseInt(body.sets_completed, 10) || 0);
    }

    if (body.increment_reps != null) {
        repsLogged += Math.max(0, parseInt(body.increment_reps, 10) || 0);
    } else if (body.reps_logged != null) {
        repsLogged = Math.max(0, parseInt(body.reps_logged, 10) || 0);
    }

    return { setsCompleted, repsLogged };
};

const assertChallengeProgressContext = async (userId, challengeId, cseId) => {
    if (!cseId) {
        throw new Error('challenge_stage_exercise_id is required');
    }

    const challenge = await Challenge.findOne({ where: { id: challengeId, status: 'published' } });
    if (!challenge) {
        throw new Error('Challenge not found or not available');
    }

    const now = new Date();
    if (now >= challenge.ends_at) {
        throw new Error('This challenge has ended');
    }
    if (now < challenge.starts_at) {
        throw new Error('This challenge has not started yet');
    }

    const userChallenge = await getUserChallengeRow(userId, challengeId);
    if (!userChallenge) {
        throw new Error('Join this challenge before logging progress');
    }
    if (['completed', 'failed', 'expired'].includes(userChallenge.status)) {
        throw new Error('This challenge enrollment is no longer active');
    }

    const cse = await ChallengeStageExercise.findByPk(cseId, {
        include: [{ model: ChallengeStage, as: 'stage' }]
    });
    if (!cse || !cse.stage || cse.stage.challenge_id !== challengeId) {
        throw new Error('Exercise does not belong to this challenge');
    }

    let ep = await UserChallengeExerciseProgress.findOne({
        where: {
            user_challenge_id: userChallenge.id,
            challenge_stage_exercise_id: cseId
        }
    });
    if (!ep) {
        await syncUserChallengeStageProgress(userChallenge.id, challengeId);
        ep = await UserChallengeExerciseProgress.findOne({
            where: {
                user_challenge_id: userChallenge.id,
                challenge_stage_exercise_id: cseId
            }
        });
        if (!ep) {
            throw new Error('Progress row not found for this exercise');
        }
    }

    const stageProg = await UserChallengeStageProgress.findOne({
        where: {
            user_challenge_id: userChallenge.id,
            challenge_stage_id: cse.challenge_stage_id
        }
    });
    if (!stageProg || stageProg.status === 'locked') {
        throw new Error('This stage is not unlocked yet');
    }
    if (stageProg.status === 'completed') {
        throw new Error('This stage is already completed');
    }

    return { userChallenge, cse, ep };
};

const applyExerciseProgressUpdate = async (userChallenge, cse, ep, body, transaction) => {
    const { setsCompleted, repsLogged } = resolveProgressCounts(body, ep);
    const formScore = normalizeFormScore(body.form_score);
    const mistakes = body.mistakes !== undefined ? normalizeMistakes(body.mistakes) : undefined;

    const wasCompleted = ep.status === 'completed';
    const meetsTarget = setsCompleted >= cse.target_sets;
    const nextStatus = meetsTarget ? 'completed' : setsCompleted > 0 ? 'in_progress' : 'not_started';

    const patch = {
        sets_completed: setsCompleted,
        reps_logged: repsLogged,
        status: nextStatus,
        completed_at: meetsTarget ? (ep.completed_at || new Date()) : null
    };
    if (formScore !== undefined) patch.form_score = formScore;
    if (mistakes !== undefined) patch.mistakes = mistakes;

    await ep.update(patch, { transaction });

    if (meetsTarget && !wasCompleted && cse.points_on_complete > 0) {
        await ep.update({ points_awarded: cse.points_on_complete }, { transaction });
        await userChallenge.increment('total_points_earned', { by: cse.points_on_complete, transaction });
    }

    if (userChallenge.status === 'joined') {
        await userChallenge.update({ status: 'in_progress' }, { transaction });
    }
};

const finalizeChallengeProgress = async (userId, userChallenge, challengeId, transaction) => {
    await userChallenge.reload({ transaction });
    await advanceStagesIfNeeded(userChallenge, transaction);
    await userChallenge.reload({ transaction });
    return evaluateAndAwardBadges(userId, userChallenge, challengeId, transaction);
};

const syncExerciseProgress = async (userId, challengeId, body) => {
    const cseId = body.challenge_stage_exercise_id != null
        ? String(body.challenge_stage_exercise_id).trim()
        : '';

    const ctx = await assertChallengeProgressContext(userId, challengeId, cseId);

    let badgesEarned = [];
    const t = await sequelize.transaction();
    try {
        await applyExerciseProgressUpdate(ctx.userChallenge, ctx.cse, ctx.ep, body, t);
        badgesEarned = await finalizeChallengeProgress(userId, ctx.userChallenge, challengeId, t);
        await t.commit();
    } catch (err) {
        await t.rollback();
        throw err;
    }

    const progress = await getMyChallengeProgress(userId, challengeId);
    return { progress, badges_earned: badgesEarned.map((b) => (b.toJSON ? b.toJSON() : b)) };
};

const syncBulkExerciseProgress = async (userId, challengeId, body) => {
    const items = Array.isArray(body.exercises) ? body.exercises : [];
    if (!items.length) {
        throw new Error('exercises array is required and must not be empty');
    }
    if (items.length > 50) {
        throw new Error('Maximum 50 exercises per bulk save');
    }

    let badgesEarned = [];
    const t = await sequelize.transaction();
    try {
        let userChallenge = null;
        for (const item of items) {
            const cseId = item.challenge_stage_exercise_id != null
                ? String(item.challenge_stage_exercise_id).trim()
                : '';
            const ctx = await assertChallengeProgressContext(userId, challengeId, cseId);
            userChallenge = ctx.userChallenge;
            await applyExerciseProgressUpdate(ctx.userChallenge, ctx.cse, ctx.ep, item, t);
        }

        badgesEarned = await finalizeChallengeProgress(userId, userChallenge, challengeId, t);
        await t.commit();
    } catch (err) {
        await t.rollback();
        throw err;
    }

    const progress = await getMyChallengeProgress(userId, challengeId);
    return {
        progress,
        badges_earned: badgesEarned.map((b) => (b.toJSON ? b.toJSON() : b)),
        saved_count: items.length
    };
};

const getChallengeLeaderboard = async (challengeId, filters = {}) => {
    const challenge = await Challenge.findOne({ where: { id: challengeId, status: 'published' } });
    if (!challenge) return null;

    const limit = Math.min(Math.max(Number(filters.limit) || 20, 1), 100);
    const page = Math.max(Number(filters.page) || 1, 1);
    const offset = (page - 1) * limit;

    const { count, rows } = await UserChallenge.findAndCountAll({
        where: { challenge_id: challengeId },
        include: [{
            model: User,
            as: 'user',
            attributes: ['id'],
            include: [{
                model: Profile,
                as: 'profile',
                attributes: ['full_name', 'avatar_url']
            }]
        }],
        order: [['total_points_earned', 'DESC'], ['joined_at', 'ASC']],
        limit,
        offset
    });

    const totalPages = Math.max(Math.ceil(count / limit), 1);
    const data = rows.map((row, index) => {
        const j = row.toJSON();
        const profile = j.user && j.user.profile;
        return {
            rank: offset + index + 1,
            user_id: j.user_id,
            display_name: profile && profile.full_name ? profile.full_name : 'Athlete',
            avatar_url: profile ? profile.avatar_url : null,
            total_points: j.total_points_earned,
            status: j.status,
            joined_at: j.joined_at
        };
    });

    return {
        challenge: {
            id: challenge.id,
            name: challenge.name
        },
        data,
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

module.exports = {
    listPublicChallenges,
    getPublicChallengeById,
    joinChallenge,
    listMyChallenges,
    getMyChallengeProgress,
    syncExerciseProgress,
    syncBulkExerciseProgress,
    getChallengeLeaderboard,
    syncUserChallengeStageProgress
};


