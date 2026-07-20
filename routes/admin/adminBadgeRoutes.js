const express = require('express');
const router = express.Router();
const { protectAdmin } = require('../../middleware/adminAuth');
const { getAdminBadges, createAdminBadge } = require('../../controllers/admin/adminBadgeController');

router.use(protectAdmin);
router.get('/', getAdminBadges);
router.post('/', createAdminBadge);

module.exports = router;
