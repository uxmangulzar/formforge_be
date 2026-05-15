const { Op } = require('sequelize');
const ExerciseCategory = require('../models/exerciseCategoryModel');

const SLUG_RE = /^[a-z][a-z0-9_]{0,63}$/;

const listAll = async () => {
    return ExerciseCategory.findAll({
        order: [['sort_order', 'ASC'], ['slug', 'ASC']]
    });
};

const normalizeSlug = (s) => (s != null ? String(s).trim().toLowerCase() : '');

const createCategory = async (body) => {
    const slug = normalizeSlug(body.slug);
    if (!slug || !SLUG_RE.test(slug)) {
        throw new Error('Slug must be lowercase letters, numbers, underscore; max 64 chars.');
    }
    const display_name = body.display_name != null ? String(body.display_name).trim() : '';
    if (!display_name) {
        throw new Error('Display name is required.');
    }
    const description =
        body.description != null ? String(body.description).trim().slice(0, 500) : null;
    const sort_order = body.sort_order != null ? parseInt(body.sort_order, 10) : 0;
    const is_active = body.is_active !== false && body.is_active !== 'false' && body.is_active !== 0;

    const clash = await ExerciseCategory.findOne({ where: { slug } });
    if (clash) throw new Error('A category with this slug already exists.');

    return ExerciseCategory.create({
        slug,
        display_name,
        description: description || null,
        sort_order: Number.isFinite(sort_order) ? sort_order : 0,
        is_active: !!is_active
    });
};

const updateCategory = async (id, body) => {
    const row = await ExerciseCategory.findByPk(id);
    if (!row) throw new Error('Category not found');

    const patch = {};
    if (body.display_name !== undefined) {
        const display_name = String(body.display_name).trim();
        if (!display_name) throw new Error('Display name cannot be empty.');
        patch.display_name = display_name;
    }
    if (body.description !== undefined) {
        const d = body.description != null ? String(body.description).trim().slice(0, 500) : null;
        patch.description = d || null;
    }
    if (body.sort_order !== undefined) {
        const n = parseInt(body.sort_order, 10);
        patch.sort_order = Number.isFinite(n) ? n : row.sort_order;
    }
    if (body.is_active !== undefined) {
        patch.is_active = !!(body.is_active !== false && body.is_active !== 'false' && body.is_active !== 0);
    }
    if (body.slug !== undefined) {
        const slug = normalizeSlug(body.slug);
        if (!slug || !SLUG_RE.test(slug)) {
            throw new Error('Slug must be lowercase letters, numbers, underscore; max 64 chars.');
        }
        const other = await ExerciseCategory.findOne({
            where: { slug, id: { [Op.ne]: id } }
        });
        if (other) throw new Error('Another category already uses this slug.');
        patch.slug = slug;
    }

    await row.update(patch);
    return ExerciseCategory.findByPk(id);
};

module.exports = {
    listAll,
    createCategory,
    updateCategory
};
