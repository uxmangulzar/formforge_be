const express = require('express');
const router = express.Router();
const { protectAdmin } = require('../../middleware/adminAuth');
const {
    getAdminNotifications,
    patchMarkNotificationRead,
    postMarkAllNotificationsRead,
    getAdminNotificationSettings,
    patchAdminNotificationSettings
} = require('../../controllers/admin/adminNotificationController');

router.use(protectAdmin);

router.get('/settings', getAdminNotificationSettings);
router.patch('/settings', patchAdminNotificationSettings);
router.get('/', getAdminNotifications);
router.post('/read-all', postMarkAllNotificationsRead);
router.patch('/:id/read', patchMarkNotificationRead);

module.exports = router;
