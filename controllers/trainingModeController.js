const trainingModeService = require('../services/trainingModeService');

const getTrainingModes = async (req, res, next) => {
    try {
        const { page, limit } = req.query;
        const result = await trainingModeService.listPublicTrainingModes({ page, limit });
        res.status(200).json({
            success: true,
            count: result.data.length,
            pagination: result.pagination,
            data: result.data
        });
    } catch (error) {
        next(error);
    }
};

const getTrainingMode = async (req, res, next) => {
    try {
        const data = await trainingModeService.getPublicTrainingMode(req.params.idOrSlug);
        if (!data) {
            res.status(404);
            throw new Error('Training mode not found');
        }
        res.status(200).json({
            success: true,
            data
        });
    } catch (error) {
        next(error);
    }
};

module.exports = {
    getTrainingModes,
    getTrainingMode
};
