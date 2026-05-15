const express = require('express');
const router = express.Router();
const { protectAdmin } = require('../../middleware/adminAuth');
const {
    getAdminTrainingModes,
    getAdminTrainingModeById,
    createAdminTrainingMode,
    updateAdminTrainingMode
} = require('../../controllers/admin/adminTrainingModeController');

router.use(protectAdmin);

router.get('/', getAdminTrainingModes);
router.post('/', createAdminTrainingMode);
router.get('/:id', getAdminTrainingModeById);
router.put('/:id', updateAdminTrainingMode);

module.exports = router;
