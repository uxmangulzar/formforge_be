const settingService = require('../../services/settingService');

const getAdminSettings = async (req, res, next) => {
    try {
        const data = await settingService.listSettings();
        res.status(200).json({ success: true, count: data.length, data });
    } catch (error) {
        next(error);
    }
};

const createAdminSetting = async (req, res, next) => {
    try {
        const data = await settingService.createSetting(req.body);
        res.status(201).json({ success: true, message: 'Setting created', data });
    } catch (error) {
        next(error);
    }
};

const updateAdminSetting = async (req, res, next) => {
    try {
        const data = await settingService.updateSetting(req.params.id, req.body);
        res.status(200).json({ success: true, message: 'Setting updated', data });
    } catch (error) {
        if (error.message === 'Setting not found') {
            res.status(404);
        }
        next(error);
    }
};

module.exports = {
    getAdminSettings,
    createAdminSetting,
    updateAdminSetting
};
