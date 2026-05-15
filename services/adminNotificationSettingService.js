const AdminNotificationSetting = require('../models/adminNotificationSettingModel');

const KNOWN_TYPES = ['system', 'waitlist', 'user_registered'];

const defaultsFor = (userId) => ({
    user_id: userId,
    in_app_enabled: true,
    email_enabled: false,
    allowed_types: null
});

const getForUser = async (userId) => {
    const row = await AdminNotificationSetting.findByPk(userId);
    if (!row) return defaultsFor(userId);
    return row.toJSON();
};

const upsertForUser = async (userId, body) => {
    const [row] = await AdminNotificationSetting.findOrCreate({
        where: { user_id: userId },
        defaults: {
            user_id: userId,
            in_app_enabled: true,
            email_enabled: false,
            allowed_types: null
        }
    });

    if (body.in_app_enabled !== undefined) {
        row.in_app_enabled =
            body.in_app_enabled !== false && body.in_app_enabled !== 'false' && body.in_app_enabled !== 0;
    }
    if (body.email_enabled !== undefined) {
        row.email_enabled =
            body.email_enabled === true || body.email_enabled === 'true' || body.email_enabled === 1;
    }
    if (body.allowed_types !== undefined) {
        if (body.allowed_types === null) {
            row.allowed_types = null;
        } else if (typeof body.allowed_types === 'object' && body.allowed_types !== null) {
            const cleaned = {};
            for (const k of KNOWN_TYPES) {
                cleaned[k] = !!body.allowed_types[k];
            }
            const allOn = KNOWN_TYPES.every((k) => cleaned[k]);
            row.allowed_types = allOn ? null : cleaned;
        }
    }

    await row.save();
    return row.toJSON();
};

module.exports = {
    getForUser,
    upsertForUser,
    KNOWN_TYPES
};
