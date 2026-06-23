const { Op, QueryTypes } = require('sequelize');
const { sequelize } = require('../database/db');
const TrainingMode = require('../models/trainingModeModel');
const Exercise = require('../models/exerciseModel');

const SLUG_RE = /^[a-z][a-z0-9_]{0,49}$/;

const fetchLinkedExercises = async (modeId, transaction = undefined) => {
    const rows = await sequelize.query(
        `SELECT e.id, e.name, e.type, c.slug AS category, e.difficulty, e.is_active AS exercise_active
         FROM exercises e
         INNER JOIN exercise_categories c ON c.id = e.category_id
         INNER JOIN exercise_training_modes etm ON etm.exercise_id = e.id AND etm.mode_id = :modeId
         ORDER BY e.name ASC`,
        { replacements: { modeId }, type: QueryTypes.SELECT, transaction }
    );
    return rows;
};

const getTrainingModeDetail = async (id) => {
    const row = await TrainingMode.findByPk(id);
    if (!row) return null;
    const exercises = await fetchLinkedExercises(id);
    return { ...row.toJSON(), exercises };
};

const listTrainingModes = async () => {
    return TrainingMode.findAll({
        order: [['sort_order', 'ASC'], ['slug', 'ASC']]
    });
};

const normalizeSlug = (s) => (s != null ? String(s).trim().toLowerCase() : '');

const validatePayload = (body) => {
    const slug = normalizeSlug(body.slug);
    if (!slug || !SLUG_RE.test(slug)) {
        throw new Error('Slug is required (lowercase letters, numbers, underscore; max 50 chars).');
    }
    const display_name = body.display_name != null ? String(body.display_name).trim() : '';
    if (!display_name) {
        throw new Error('Display name is required.');
    }
    const description = body.description != null ? String(body.description).trim().slice(0, 500) : null;
    const sort_order = body.sort_order != null ? parseInt(body.sort_order, 10) : 0;
    const is_active = body.is_active !== false && body.is_active !== 'false' && body.is_active !== 0;

    return {
        slug,
        display_name,
        description: description || null,
        sort_order: Number.isFinite(sort_order) ? sort_order : 0,
        is_active: !!is_active
    };
};

const syncModeExercises = async (modeId, exerciseIdsInput, transaction) => {
    let ids = Array.isArray(exerciseIdsInput) ? exerciseIdsInput.map((x) => String(x).trim()).filter(Boolean) : [];
    ids = [...new Set(ids)];

    await sequelize.query('DELETE FROM exercise_training_modes WHERE mode_id = :modeId', {
        replacements: { modeId },
        transaction
    });

    if (!ids.length) return;

    const found = await Exercise.findAll({
        where: { id: { [Op.in]: ids } },
        attributes: ['id'],
        transaction
    });
    const ok = new Set(found.map((f) => f.id));
    const finalIds = ids.filter((i) => ok.has(i));

    for (const exId of finalIds) {
        await sequelize.query(
            `INSERT INTO exercise_training_modes (exercise_id, mode_id, createdAt, updatedAt)
             VALUES (:exId, :modeId, NOW(), NOW())`,
            { replacements: { exId, modeId }, transaction }
        );
    }
};

const createTrainingMode = async (body) => {
    const data = validatePayload(body);
    const exists = await TrainingMode.findOne({ where: { slug: data.slug } });
    if (exists) {
        throw new Error('A mode with this slug already exists.');
    }

    const t = await sequelize.transaction();
    try {
        const mode = await TrainingMode.create(data, { transaction: t });
        if (body.exercise_ids !== undefined) {
            await syncModeExercises(mode.id, body.exercise_ids, t);
        }
        await t.commit();
        return getTrainingModeDetail(mode.id);
    } catch (err) {
        await t.rollback();
        throw err;
    }
};

const updateTrainingMode = async (id, body) => {
    const row = await TrainingMode.findByPk(id);
    if (!row) {
        throw new Error('Training mode not found');
    }
    const data = validatePayload(body);
    if (data.slug !== row.slug) {
        const clash = await TrainingMode.findOne({
            where: { slug: data.slug, id: { [Op.ne]: id } }
        });
        if (clash) {
            throw new Error('Another mode already uses this slug.');
        }
    }

    const t = await sequelize.transaction();
    try {
        await row.update(data, { transaction: t });
        if (body.exercise_ids !== undefined) {
            await syncModeExercises(id, body.exercise_ids, t);
        }
        await t.commit();
        return getTrainingModeDetail(id);
    } catch (err) {
        await t.rollback();
        throw err;
    }
};

const UUID_RE = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

const PUBLIC_MODE_ATTRS = ['id', 'slug', 'display_name', 'description', 'sort_order'];

const fetchLinkedExercisesPublic = async (modeId) => {
    const rows = await sequelize.query(
        `SELECT e.id, e.name, e.type, c.slug AS category, c.display_name AS category_display_name,
                e.difficulty, e.description, e.demo_url, e.gif_url, e.data_url, e.target_muscles,
                e.logic_config, e.rep_counting_logic
         FROM exercises e
         INNER JOIN exercise_categories c ON c.id = e.category_id AND c.is_active = TRUE
         INNER JOIN exercise_training_modes etm ON etm.exercise_id = e.id AND etm.mode_id = :modeId
         WHERE e.is_active = TRUE
         ORDER BY e.name ASC`,
        { replacements: { modeId }, type: QueryTypes.SELECT }
    );
    return rows;
};

const listPublicTrainingModes = async (filters = {}) => {
    const limit = Math.min(Math.max(Number(filters.limit) || 10, 1), 50);
    const page = Math.max(Number(filters.page) || 1, 1);
    const offset = (page - 1) * limit;

    const { count, rows } = await TrainingMode.findAndCountAll({
        where: { is_active: true },
        order: [['sort_order', 'ASC'], ['slug', 'ASC']],
        attributes: PUBLIC_MODE_ATTRS,
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

const getPublicTrainingMode = async (idOrSlug) => {
    const key = String(idOrSlug || '').trim();
    if (!key) return null;

    const where = UUID_RE.test(key) ? { id: key, is_active: true } : { slug: key.toLowerCase(), is_active: true };
    const row = await TrainingMode.findOne({
        where,
        attributes: PUBLIC_MODE_ATTRS
    });
    if (!row) return null;

    const exercises = await fetchLinkedExercisesPublic(row.id);
    return { ...row.toJSON(), exercises };
};

module.exports = {
    listTrainingModes,
    getTrainingModeDetail,
    createTrainingMode,
    updateTrainingMode,
    listPublicTrainingModes,
    getPublicTrainingMode
};
