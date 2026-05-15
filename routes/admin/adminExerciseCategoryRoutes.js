const express = require('express');
const router = express.Router();
const { protectAdmin } = require('../../middleware/adminAuth');
const {
    getCategories,
    createCategory,
    updateCategory
} = require('../../controllers/admin/adminExerciseCategoryController');

router.use(protectAdmin);

router.get('/', getCategories);
router.post('/', createCategory);
router.patch('/:id', updateCategory);

module.exports = router;
