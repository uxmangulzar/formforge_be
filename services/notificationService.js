const { Op } = require('sequelize');
const Notification = require('../models/notificationModel');

const applyDisplaySettings = (rows, settings) => {
    if (!settings || settings.in_app_enabled === false) return [];
    if (!settings.allowed_types) return rows;
    return rows.filter((r) => settings.allowed_types[r.type] !== false);
};

const listForRecipient = async (recipientUserId, { limit = 30, unreadOnly = false } = {}, settings = null) => {
    const cap = Math.min(Math.max(parseInt(limit, 10) || 30, 1), 100);
    const where = { recipient_user_id: recipientUserId };
    if (unreadOnly) {
        where.read_at = { [Op.is]: null };
    }
    const rows = await Notification.findAll({
        where,
        order: [['createdAt', 'DESC']],
        limit: cap
    });
    return applyDisplaySettings(rows, settings);
};

const countUnread = async (recipientUserId, settings = null) => {
    if (settings && settings.in_app_enabled === false) return 0;
    const where = { recipient_user_id: recipientUserId, read_at: { [Op.is]: null } };
    if (settings && settings.allowed_types) {
        const allowed = Object.entries(settings.allowed_types)
            .filter(([, v]) => v)
            .map(([k]) => k);
        if (!allowed.length) return 0;
        where.type = { [Op.in]: allowed };
    }
    return Notification.count({ where });
};

const markAsRead = async (recipientUserId, notificationId) => {
    const n = await Notification.findOne({
        where: { id: notificationId, recipient_user_id: recipientUserId }
    });
    if (!n) {
        throw new Error('Notification not found');
    }
    if (!n.read_at) {
        n.read_at = new Date();
        await n.save();
    }
    return n;
};

const markAllRead = async (recipientUserId) => {
    await Notification.update(
        { read_at: new Date() },
        { where: { recipient_user_id: recipientUserId, read_at: { [Op.is]: null } } }
    );
};

module.exports = {
    listForRecipient,
    countUnread,
    markAsRead,
    markAllRead
};
