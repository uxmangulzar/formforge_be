const { Op } = require('sequelize');
const Setting = require('../models/settingModel');

const KEY_PATTERN = /^[a-z][a-z0-9_]{0,99}$/i;

const normalizeKey = (key) => (key != null ? String(key).trim() : '');

const listSettings = async () => {
    return Setting.findAll({
        order: [['setting_key', 'ASC']]
    });
};

const getSettingById = async (id) => {
    return Setting.findByPk(id);
};

const createSetting = async (payload) => {
    const setting_key = normalizeKey(payload.setting_key);
    if (!setting_key || !KEY_PATTERN.test(setting_key)) {
        throw new Error('setting_key is required (letters, numbers, underscore; max 100 chars).');
    }
    const exists = await Setting.findOne({ where: { setting_key } });
    if (exists) {
        throw new Error('A setting with this key already exists.');
    }
    return Setting.create({
        setting_key,
        setting_value: payload.setting_value != null ? String(payload.setting_value) : null,
        description: payload.description != null ? String(payload.description).trim().slice(0, 255) : null,
        is_active: payload.is_active !== false
    });
};

const updateSetting = async (id, payload) => {
    const row = await Setting.findByPk(id);
    if (!row) {
        throw new Error('Setting not found');
    }

    const updates = {};
    if (payload.setting_value !== undefined) {
        updates.setting_value = payload.setting_value == null ? null : String(payload.setting_value);
    }
    if (payload.description !== undefined) {
        updates.description = payload.description == null ? null : String(payload.description).trim().slice(0, 255);
    }
    if (payload.is_active !== undefined) {
        updates.is_active = !!payload.is_active;
    }
    if (payload.setting_key !== undefined) {
        const nk = normalizeKey(payload.setting_key);
        if (!nk || !KEY_PATTERN.test(nk)) {
            throw new Error('Invalid setting_key.');
        }
        if (nk !== row.setting_key) {
            const clash = await Setting.findOne({
                where: { setting_key: nk, id: { [Op.ne]: id } }
            });
            if (clash) {
                throw new Error('Another setting already uses this key.');
            }
            updates.setting_key = nk;
        }
    }

    await row.update(updates);
    return row.reload();
};

module.exports = {
    listSettings,
    getSettingById,
    createSetting,
    updateSetting
};
