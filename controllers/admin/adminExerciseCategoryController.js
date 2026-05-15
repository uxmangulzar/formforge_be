const exerciseCategoryService = require('../../services/exerciseCategoryService');

const getCategories = async (req, res, next) => {
    try {
        const data = await exerciseCategoryService.listAll();
        res.status(200).json({ success: true, count: data.length, data });
    } catch (e) {
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

module.exports = {
    getCategories,
    createCategory,
    updateCategory
};
