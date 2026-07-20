const express = require('express');
const router = express.Router();
const { protectAdmin } = require('../../middleware/adminAuth');
const {
    getAdminSettings,
    createAdminSetting,
    updateAdminSetting
} = require('../../controllers/admin/adminSettingController');

router.use(protectAdmin);

router.get('/', getAdminSettings);
router.post('/', createAdminSetting);
router.put('/:id', updateAdminSetting);

module.exports = router;
