const exerciseCategoryService = require('../../services/exerciseCategoryService');

const getCategories = async (req, res, next) => {
    try {
        const data = await exerciseCategoryService.listAll();
        res.status(200).json({ success: true, count: data.length, data });
    } catch (e) {
        next(e);
    }
};

const getCategoryById = async (req, res, next) => {
    try {
        const data = await exerciseCategoryService.getById(req.params.id);
        res.status(200).json({ success: true, data });
    } catch (e) {
        if (e.message === 'Category not found') res.status(404);
        next(e);
    }
};

const createCategory = async (req, res, next) => {
    try {
        const data = await exerciseCategoryService.createCategory(req.body);
        res.status(201).json({ success: true, message: 'Category created', data });
    } catch (e) {
        next(e);
    }
};

const updateCategory = async (req, res, next) => {
    try {
        const data = await exerciseCategoryService.updateCategory(req.params.id, req.body);
        res.status(200).json({ success: true, message: 'Category updated', data });
    } catch (e) {
        if (e.message === 'Category not found') res.status(404);
        next(e);
    }
};

const assignExercisesToCategory = async (req, res, next) => {
    try {
        const { exercise_ids } = req.body;
        const data = await exerciseCategoryService.assignExercises(req.params.id, exercise_ids);
        res.status(200).json({
            success: true,
            message: `${data.assigned_count} exercise(s) added to category`,
            data
        });
    } catch (e) {
        if (e.message === 'Category not found') res.status(404);
        else if (e.message === 'Select at least one exercise' || e.message === 'No matching exercises found') {
            res.status(400);
        }
        next(e);
    }
};

module.exports = {
    getCategories,
    getCategoryById,
    createCategory,
    updateCategory,
    assignExercisesToCategory
};
