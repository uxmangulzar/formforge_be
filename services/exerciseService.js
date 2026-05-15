const Exercise = require('../models/exerciseModel');
const ExerciseCategory = require('../models/exerciseCategoryModel');
const { sequelize } = require('../database/db');

const exerciseCategoryInclude = {
    model: ExerciseCategory,
    as: 'exerciseCategory',
    attributes: ['id', 'slug', 'display_name', 'sort_order', 'is_active'],
    required: false
};

const getAllExercises = async (filters = {}) => {
    const { categorySlug, ...where } = filters;
    const include = { ...exerciseCategoryInclude };
    if (categorySlug) {
        include.where = { slug: categorySlug };
        include.required = true;
    }
    return Exercise.findAll({
        where,
        include: [include],
        order: [['createdAt', 'DESC']]
    });
};

const getExerciseById = async (id) => {
    return Exercise.findByPk(id, { include: [exerciseCategoryInclude] });
};

const listCategoriesPublic = async () => {
    return ExerciseCategory.findAll({
        where: { is_active: true },
        order: [['sort_order', 'ASC'], ['display_name', 'ASC']],
        attributes: ['id', 'slug', 'display_name', 'description', 'sort_order']
    });
};

const resolveCategoryId = async (payload, { required } = { required: true }) => {
    const hasId = payload.category_id != null && String(payload.category_id).trim() !== '';
    const hasSlug = payload.category != null && String(payload.category).trim() !== '';
    if (hasId) {
        const id = String(payload.category_id).trim();
        const row = await ExerciseCategory.findByPk(id);
        if (!row) throw new Error('Invalid category_id');
        if (!row.is_active) throw new Error('Category is inactive');
        return id;
    }
    if (hasSlug) {
        const label = String(payload.category).trim();
        const slugGuess = label.toLowerCase().replace(/\s+/g, '_');

        let row = await ExerciseCategory.findOne({ where: { slug: label } });
        if (!row) {
            row = await ExerciseCategory.findOne({ where: { slug: slugGuess } });
        }
        if (!row) {
            row = await ExerciseCategory.findOne({
                where: sequelize.where(
                    sequelize.fn('LOWER', sequelize.col('display_name')),
                    label.toLowerCase()
                )
            });
        }
        if (!row) throw new Error(`Unknown category: ${label}`);
        if (!row.is_active) throw new Error('Category is inactive');
        return row.id;
    }
    if (required) throw new Error('category_id or category is required');
    return null;
};

const createExercise = async (exerciseData) => {
    const category_id = await resolveCategoryId(exerciseData, { required: true });
    const {
        name,
        type,
        description,
        demo_url,
        data_url,
        gif_url,
        difficulty,
        target_muscles,
        logic_config,
        rep_counting_logic,
        is_active
    } = exerciseData;
    return Exercise.create({
        name,
        type,
        category_id,
        description,
        demo_url,
        data_url,
        gif_url,
        difficulty,
        target_muscles,
        logic_config,
        rep_counting_logic,
        is_active
    }).then((row) => getExerciseById(row.id));
};

const updateExercise = async (id, updateData) => {
    const exercise = await Exercise.findByPk(id, { include: [exerciseCategoryInclude] });
    if (!exercise) {
        throw new Error('Exercise not found');
    }
    const patch = { ...updateData };
    delete patch.category;

    const changingCat =
        updateData.category_id !== undefined ||
        (updateData.category !== undefined && String(updateData.category).trim() !== '');

    if (changingCat) {
        patch.category_id = await resolveCategoryId(
            {
                category_id: updateData.category_id,
                category: updateData.category
            },
            { required: true }
        );
    }

    const allowed = [
        'name',
        'type',
        'category_id',
        'description',
        'demo_url',
        'data_url',
        'gif_url',
        'difficulty',
        'target_muscles',
        'logic_config',
        'rep_counting_logic',
        'is_active'
    ];
    const data = {};
    for (const k of allowed) {
        if (patch[k] !== undefined) data[k] = patch[k];
    }
    await exercise.update(data);
    return getExerciseById(id);
};

const deleteExercise = async (id) => {
    const exercise = await Exercise.findByPk(id);
    if (!exercise) {
        throw new Error('Exercise not found');
    }
    return exercise.update({ is_active: false });
};

module.exports = {
    getAllExercises,
    getExerciseById,
    listCategoriesPublic,
    createExercise,
    updateExercise,
    deleteExercise
};
