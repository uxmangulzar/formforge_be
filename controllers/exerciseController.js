const exerciseService = require('../services/exerciseService');

const getExerciseCategories = async (req, res, next) => {
    try {
        const data = await exerciseService.listCategoriesPublic();
        res.status(200).json({ success: true, count: data.length, data });
    } catch (error) {
        next(error);
    }
};

const getExercises = async (req, res, next) => {
    try {
        const { type, category, difficulty } = req.query;
        const filters = {};
        if (type) filters.type = type;
        if (category) filters.categorySlug = category;
        if (difficulty) filters.difficulty = difficulty;

        const exercises = await exerciseService.getAllExercises(filters);
        res.status(200).json({
            success: true,
            count: exercises.length,
            data: exercises
        });
    } catch (error) {
        next(error);
    }
};

const getExercise = async (req, res, next) => {
    try {
        const exercise = await exerciseService.getExerciseById(req.params.id);
        if (!exercise) {
            res.status(404);
            throw new Error('Exercise not found');
        }
        res.status(200).json({
            success: true,
            data: exercise
        });
    } catch (error) {
        next(error);
    }
};

const createExercise = async (req, res, next) => {
    try {
        const exercise = await exerciseService.createExercise(req.body);
        res.status(201).json({
            success: true,
            message: 'Exercise created successfully',
            data: exercise
        });
    } catch (error) {
        next(error);
    }
};

const updateExercise = async (req, res, next) => {
    try {
        const exercise = await exerciseService.updateExercise(req.params.id, req.body);
        res.status(200).json({
            success: true,
            message: 'Exercise updated successfully',
            data: exercise
        });
    } catch (error) {
        next(error);
    }
};

const deleteExercise = async (req, res, next) => {
    try {
        await exerciseService.deleteExercise(req.params.id);
        res.status(200).json({
            success: true,
            message: 'Exercise deleted successfully'
        });
    } catch (error) {
        next(error);
    }
};

module.exports = {
    getExerciseCategories,
    getExercises,
    getExercise,
    createExercise,
    updateExercise,
    deleteExercise
};
