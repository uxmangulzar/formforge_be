const express = require('express');
const router = express.Router();
const { protectAdmin } = require('../../middleware/adminAuth');
const {
    getCategories,
    getCategoryById,
    createCategory,
    updateCategory,
    assignExercisesToCategory
} = require('../../controllers/admin/adminExerciseCategoryController');

router.use(protectAdmin);

router.get('/', getCategories);
router.post('/', createCategory);
router.post('/:id/exercises', assignExercisesToCategory);
router.get('/:id', getCategoryById);
router.patch('/:id', updateCategory);

module.exports = router;
