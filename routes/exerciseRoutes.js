const express = require('express');
const router = express.Router();
const {
    getExerciseCategories,
    getExercises,
    getExercise,
    createExercise,
    updateExercise,
    deleteExercise
} = require('../controllers/exerciseController');

const { protectAdmin } = require('../middleware/adminAuth');

// Public routes (categories before /:id)
router.get('/categories', getExerciseCategories);
router.get('/', getExercises);
router.get('/:id', getExercise);

// Admin/Mock routes (Create/Update/Delete) - Protected
router.post('/', protectAdmin, createExercise);
router.put('/:id', protectAdmin, updateExercise);
router.delete('/:id', protectAdmin, deleteExercise);

module.exports = router;
