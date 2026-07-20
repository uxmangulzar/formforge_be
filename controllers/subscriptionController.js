const mobileSubscriptionService = require('../services/mobileSubscriptionService');

const getPlans = async (req, res, next) => {
    try {
        const { page, limit } = req.query;
        const result = await mobileSubscriptionService.listPublicPlans({ page, limit });
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

const getMySubscription = async (req, res, next) => {
    try {
        const data = await mobileSubscriptionService.getMySubscription(req.user.id);
        res.status(200).json({ success: true, data });
    } catch (error) {
        next(error);
    }
};

const subscribe = async (req, res, next) => {
    try {
        const data = await mobileSubscriptionService.subscribeUser(req.user.id, req.body);
        res.status(200).json({
            success: true,
            message: 'Subscription activated',
            data
        });
    } catch (error) {
        if (
            error.message.includes('required') ||
            error.message.includes('not found') ||
            error.message.includes('must be') ||
            error.message.includes('does not match') ||
            error.message.includes('not configured') ||
            error.message.includes('not linked')
        ) {
            res.status(400);
        }
        next(error);
    }
};

const restore = async (req, res, next) => {
    try {
        const data = await mobileSubscriptionService.restoreUserSubscription(req.user.id, req.body);
        res.status(200).json({
            success: true,
            message: 'Purchases restored',
            data
        });
    } catch (error) {
        if (
            error.message.includes('required') ||
            error.message.includes('not found') ||
            error.message.includes('must be') ||
            error.message.includes('does not match') ||
            error.message.includes('not configured') ||
            error.message.includes('not linked')
        ) {
            res.status(400);
        }
        next(error);
    }
};

module.exports = {
    getPlans,
    getMySubscription,
    subscribe,
    restore
};
