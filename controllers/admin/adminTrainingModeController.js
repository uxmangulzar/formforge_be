const trainingModeService = require('../../services/trainingModeService');

const getAdminTrainingModes = async (req, res, next) => {
    try {
        const data = await trainingModeService.listTrainingModes();
        res.status(200).json({
            success: true,
            count: data.length,
            data
        });
    } catch (error) {
        next(error);
    }
};

const getAdminTrainingModeById = async (req, res, next) => {
    try {
        const data = await trainingModeService.getTrainingModeDetail(req.params.id);
        if (!data) {
            res.status(404);
            throw new Error('Training mode not found');
        }
        res.status(200).json({ success: true, data });
    } catch (error) {
        next(error);
    }
};

const createAdminTrainingMode = async (req, res, next) => {
    try {
        const data = await trainingModeService.createTrainingMode(req.body);
        res.status(201).json({ success: true, message: 'Training mode created', data });
    } catch (error) {
        next(error);
    }
};

const updateAdminTrainingMode = async (req, res, next) => {
    try {
        const data = await trainingModeService.updateTrainingMode(req.params.id, req.body);
        res.status(200).json({ success: true, message: 'Training mode updated', data });
    } catch (error) {
        if (error.message === 'Training mode not found') {
            res.status(404);
        }
        next(error);
    }
};

module.exports = {
    getAdminTrainingModes,
    getAdminTrainingModeById,
    createAdminTrainingMode,
    updateAdminTrainingMode
};
