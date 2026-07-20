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
const User = require('../models/userModel');
const Profile = require('../models/profileModel');

const challengeDetailInclude = (challengePk) => [{
    model: ChallengeStage,
    as: 'stages',
    include: [{
        model: ChallengeStageExercise,
        as: 'stageExercises',
        include: [{
            model: Exercise,
            as: 'exercise',
            attributes: ['id', 'name', 'type', 'category'],
            include: [{
                model: ExerciseCategory,
                as: 'exerciseCategory',
                attributes: ['slug', 'display_name'],
                required: false
            }]
        }]
    }]
}, {
    model: Badge,
    as: 'challengeBadges',
    where: { challenge_id: challengePk },
    required: false,
    include: [{
        model: BadgeRule,
        as: 'rules',
        where: { challenge_id: challengePk },
        required: false
    }]
}, {
    model: UserChallenge,
    as: 'userChallenges',
    required: false,
    separate: true,
    order: [['joined_at', 'DESC']],
    include: [{
        model: User,
        as: 'user',
        attributes: ['id', 'email'],
        include: [{
            model: Profile,
            as: 'profile',
            attributes: ['full_name', 'avatar_url']
        }]
    }]
}];

const findChallengeDetailById = (id) =>
    Challenge.findByPk(id, {
        include: challengeDetailInclude(id),
        order: [[{ model: ChallengeStage, as: 'stages' }, 'stage_order', 'ASC']]
    });

const MAX_MEDIA_URLS = 20;
const MAX_MEDIA_URL_LEN = 512;

const normalizeUrlArray = (raw) => {
    let arr = [];
    if (raw == null) return [];
    if (Array.isArray(raw)) arr = raw;
    else if (typeof raw === 'string') {
        try {
            const p = JSON.parse(raw);
            if (Array.isArray(p)) arr = p;
        } catch {
            return [];
        }
    } else {
        return [];
    }
    const out = [];
    for (const item of arr) {
        if (out.length >= MAX_MEDIA_URLS) break;
        if (item == null) continue;
        const s = String(item).trim();
        if (!s || s.length > MAX_MEDIA_URL_LEN) continue;
        if (s.startsWith('/') && !s.startsWith('//')) {
            if (s.startsWith('/uploads/')) out.push(s);
            continue;
        }
        if (/^https?:\/\//i.test(s)) out.push(s);
    }
    return out;
};

const allowedTriggers = ['points_threshold', 'challenge_complete', 'challenge_all_stages', 'custom'];

const validateChallengeBadgesInput = (rowsInput) => {
    const rows = Array.isArray(rowsInput) ? rowsInput : [];
    const out = [];
    for (const raw of rows) {
        if (!raw) continue;
        const name = raw.name != null ? String(raw.name).trim() : '';
        const id = raw.id || null;
        if (!id && !name) continue;
        const tt = raw.trigger_type && allowedTriggers.includes(raw.trigger_type)
            ? raw.trigger_type
            : 'challenge_complete';
        let trigger_config = raw.trigger_config != null ? raw.trigger_config : null;
        if (tt === 'points_threshold') {
            const mp = raw.min_points != null ? parseInt(raw.min_points, 10) : (trigger_config && trigger_config.min_points);
            trigger_config = { min_points: Number.isFinite(mp) ? mp : 0 };
        }
        out.push({
            id,
            name: name || null,
            description: raw.description ? String(raw.description).trim() : null,
            icon_url: raw.icon_url ? String(raw.icon_url).trim() : null,
            rarity: ['common', 'rare', 'epic', 'legendary'].includes(raw.rarity) ? raw.rarity : 'common',
            trigger_type: tt,
            trigger_config
        });
    }
    return out;
};

const validateChallengePayload = (payload) => {
    const {
        name,
        description,
        starts_at,
        ends_at,
        status,
        stages: stagesInput = [],
        challenge_badges: challengeBadgesInput = [],
        image_urls: imageUrlsInput,
        video_urls: videoUrlsInput
    } = payload;

    if (!name || typeof name !== 'string' || !name.trim()) {
        throw new Error('Challenge name is required');
    }
    if (!starts_at || !ends_at) {
        throw new Error('starts_at and ends_at are required');
    }

    const start = new Date(starts_at);
    const end = new Date(ends_at);
    if (Number.isNaN(start.getTime()) || Number.isNaN(end.getTime())) {
        throw new Error('Invalid date values');
    }
    if (start >= end) {
        throw new Error('ends_at must be after starts_at');
    }

    const allowedStatus = ['draft', 'published', 'archived'];
    const st = status && allowedStatus.includes(status) ? status : 'draft';

    return {
        name: name.trim(),
        description: description ? String(description).trim() : null,
        image_urls: normalizeUrlArray(imageUrlsInput),
        video_urls: normalizeUrlArray(videoUrlsInput),
        start,
        end,
        status: st,
        stages: Array.isArray(stagesInput) ? stagesInput : [],
        challengeBadges: validateChallengeBadgesInput(challengeBadgesInput)
    };
};

const syncChallengeScopedBadges = async (challengeId, rows, transaction, { deactivateMissing }) => {
    await BadgeRule.destroy({ where: { challenge_id: challengeId }, transaction });

    const keptIds = [];
    for (const row of rows) {
        let badge;
        if (row.id) {
            badge = await Badge.findOne({
                where: { id: row.id, challenge_id: challengeId },
                transaction
            });
            if (!badge) {
                throw new Error(`Badge not found for this challenge: ${row.id}`);
            }
            await badge.update({
                name: row.name || badge.name,
                description: row.description,
                icon_url: row.icon_url,
                rarity: row.rarity,
                is_active: true
            }, { transaction });
        } else {
            const nm = row.name && String(row.name).trim();
            if (!nm) continue;
            badge = await Badge.create({
                challenge_id: challengeId,
                name: nm,
                description: row.description,
                icon_url: row.icon_url,
                rarity: row.rarity,
                is_active: true
            }, { transaction });
        }
        keptIds.push(badge.id);

        await BadgeRule.create({
            badge_id: badge.id,
            challenge_id: challengeId,
            trigger_type: row.trigger_type,
            trigger_config: row.trigger_config,
            priority: 0,
            is_active: true
        }, { transaction });
    }

    if (deactivateMissing) {
        const where = { challenge_id: challengeId };
        if (keptIds.length) {
            where.id = { [Op.notIn]: keptIds };
        }
        await Badge.update({ is_active: false }, { where, transaction });
    }
};

const createNestedStages = async (challengeId, stages, transaction) => {
    let stageIndex = 0;
    for (const raw of stages) {
        stageIndex += 1;
        const title = raw.title != null ? String(raw.title).trim() : '';
        if (!title) {
            throw new Error(`Stage ${stageIndex}: title is required`);
        }

        const stageOrder = raw.stage_order != null ? parseInt(raw.stage_order, 10) : stageIndex;
        const stage = await ChallengeStage.create({
            challenge_id: challengeId,
            stage_order: Number.isFinite(stageOrder) ? stageOrder : stageIndex,
            title,
            description: raw.description ? String(raw.description).trim() : null,
            points_bonus: Math.max(0, parseInt(raw.points_bonus, 10) || 0)
        }, { transaction });

        const exercises = Array.isArray(raw.exercises) ? raw.exercises : [];
        let seq = 0;
        for (const ex of exercises) {
            if (!ex || !ex.exercise_id) continue;
            seq += 1;
            const exercise = await Exercise.findByPk(ex.exercise_id, { transaction });
            if (!exercise) {
                throw new Error(`Exercise not found: ${ex.exercise_id}`);
            }
            const sequenceOrder = ex.sequence_order != null ? parseInt(ex.sequence_order, 10) : seq;
            await ChallengeStageExercise.create({
                challenge_stage_id: stage.id,
                exercise_id: ex.exercise_id,
                sequence_order: Number.isFinite(sequenceOrder) ? sequenceOrder : seq,
                target_sets: Math.max(1, parseInt(ex.target_sets, 10) || 1),
                target_reps: Math.max(1, parseInt(ex.target_reps, 10) || 1),
                points_on_complete: Math.max(0, parseInt(ex.points_on_complete, 10) || 0),
                optional: !!ex.optional,
                notes: ex.notes ? String(ex.notes).trim().slice(0, 500) : null
            }, { transaction });
        }
    }
};

const getAllChallengesForAdmin = async () => {
    const rows = await Challenge.findAll({
        include: [{
            model: ChallengeStage,
            as: 'stages',
            attributes: ['id'],
            required: false
        }],
        order: [['createdAt', 'DESC']]
    });

    return rows.map((c) => {
        const j = c.toJSON();
        const stageCount = Array.isArray(j.stages) ? j.stages.length : 0;
        delete j.stages;
        return { ...j, stage_count: stageCount };
    });
};

const getChallengeByIdForAdmin = async (id) => {
    return findChallengeDetailById(id);
};

const createChallenge = async (payload) => {
    const parsed = validateChallengePayload(payload);

    let createdId;
    const t = await sequelize.transaction();
    try {
        const challenge = await Challenge.create({
            name: parsed.name,
            description: parsed.description,
            image_urls: parsed.image_urls,
            video_urls: parsed.video_urls,
            starts_at: parsed.start,
            ends_at: parsed.end,
            status: parsed.status
        }, { transaction: t });

        createdId = challenge.id;
        await createNestedStages(createdId, parsed.stages, t);
        await syncChallengeScopedBadges(createdId, parsed.challengeBadges, t, { deactivateMissing: false });
        await t.commit();
    } catch (err) {
        await t.rollback();
        throw err;
    }

    return findChallengeDetailById(createdId);
};

const updateChallenge = async (id, payload) => {
    const challenge = await Challenge.findByPk(id);
    if (!challenge) {
        throw new Error('Challenge not found');
    }

    const parsed = validateChallengePayload(payload);

    const t = await sequelize.transaction();
    try {
        await ChallengeStage.destroy({ where: { challenge_id: id }, transaction: t });
        await challenge.update({
            name: parsed.name,
            description: parsed.description,
            image_urls: parsed.image_urls,
            video_urls: parsed.video_urls,
            starts_at: parsed.start,
            ends_at: parsed.end,
            status: parsed.status
        }, { transaction: t });
        await createNestedStages(id, parsed.stages, t);
        await syncChallengeScopedBadges(id, parsed.challengeBadges, t, { deactivateMissing: true });
        await t.commit();
    } catch (err) {
        await t.rollback();
        throw err;
    }

    return findChallengeDetailById(id);
};

const deleteChallenge = async (id) => {
    const n = await Challenge.destroy({ where: { id } });
    if (!n) {
        throw new Error('Challenge not found');
    }
    return true;
};

const getChallengeLeaderboardForAdmin = async (challengeId, filters = {}) => {
    const challenge = await Challenge.findByPk(challengeId, {
        attributes: ['id', 'name', 'status', 'starts_at', 'ends_at']
    });
    if (!challenge) return null;

    const limit = Math.min(Math.max(Number(filters.limit) || 20, 1), 100);
    const page = Math.max(Number(filters.page) || 1, 1);
    const offset = (page - 1) * limit;

    const { count, rows } = await UserChallenge.findAndCountAll({
        where: { challenge_id: challengeId },
        include: [{
            model: User,
            as: 'user',
            attributes: ['id', 'email', 'status'],
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
        const user = j.user || {};
        const profile = user.profile || {};
        return {
            rank: offset + index + 1,
            user_id: j.user_id,
            email: user.email || null,
            display_name: profile.full_name || user.email || 'Athlete',
            avatar_url: profile.avatar_url || null,
            user_status: user.status || null,
            total_points: j.total_points_earned ?? 0,
            challenge_status: j.status,
            joined_at: j.joined_at,
            completed_at: j.completed_at || null
        };
    });

    return {
        challenge: challenge.toJSON(),
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
    getAllChallengesForAdmin,
    getChallengeByIdForAdmin,
    getChallengeLeaderboardForAdmin,
    createChallenge,
    updateChallenge,
    deleteChallenge
};
