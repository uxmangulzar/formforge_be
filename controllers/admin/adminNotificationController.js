const notificationService = require('../../services/notificationService');
const adminNotificationSettingService = require('../../services/adminNotificationSettingService');

const getAdminNotifications = async (req, res, next) => {
    try {
        const limit = req.query.limit;
        const unreadOnly =
            req.query.unread_only === 'true' || req.query.unread_only === '1' || req.query.unread === '1';

        const settings = await adminNotificationSettingService.getForUser(req.user.id);

        const [data, unread_count] = await Promise.all([
            notificationService.listForRecipient(req.user.id, { limit, unreadOnly }, settings),
            notificationService.countUnread(req.user.id, settings)
        ]);

        const rows = data.map((n) => n.toJSON());
        res.status(200).json({
            success: true,
            unread_count,
            count: rows.length,
            data: rows,
            settings: {
                in_app_enabled: settings.in_app_enabled !== false,
                email_enabled: !!settings.email_enabled,
                allowed_types: settings.allowed_types
            }
        });
    } catch (error) {
        next(error);
    }
};

const patchMarkNotificationRead = async (req, res, next) => {
    try {
        const row = await notificationService.markAsRead(req.user.id, req.params.id);
        const settings = await adminNotificationSettingService.getForUser(req.user.id);
        const unread_count = await notificationService.countUnread(req.user.id, settings);
        res.status(200).json({
            success: true,
            unread_count,
            data: row.toJSON()
        });
    } catch (error) {
        if (error.message === 'Notification not found') {
            res.status(404);
        }
        next(error);
    }
};

const postMarkAllNotificationsRead = async (req, res, next) => {
    try {
        await notificationService.markAllRead(req.user.id);
        const settings = await adminNotificationSettingService.getForUser(req.user.id);
        const unread_count = await notificationService.countUnread(req.user.id, settings);
        res.status(200).json({ success: true, unread_count });
    } catch (error) {
        next(error);
    }
};

const getAdminNotificationSettings = async (req, res, next) => {
    try {
        const data = await adminNotificationSettingService.getForUser(req.user.id);
        res.status(200).json({ success: true, data });
    } catch (error) {
        next(error);
    }
};

const patchAdminNotificationSettings = async (req, res, next) => {
    try {
        const data = await adminNotificationSettingService.upsertForUser(req.user.id, req.body);
        res.status(200).json({ success: true, data });
    } catch (error) {
        next(error);
    }
};

module.exports = {
    getAdminNotifications,
    patchMarkNotificationRead,
    postMarkAllNotificationsRead,
    getAdminNotificationSettings,
    patchAdminNotificationSettings
};
