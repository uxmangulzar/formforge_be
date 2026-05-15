const userSubscriptionService = require('../../services/userSubscriptionService');

const getAdminUserSubscriptionById = async (req, res, next) => {
    try {
        const data = await userSubscriptionService.getUserSubscriptionById(req.params.id);
        if (!data) {
            res.status(404);
            throw new Error('User subscription not found');
        }
        res.status(200).json({ success: true, data });
    } catch (error) {
        if (error.message === 'User subscription not found') {
            res.status(404);
        }
        next(error);
    }
};

const getAdminUserSubscriptions = async (req, res, next) => {
    try {
        const listFilters = {
            user_id: req.query.user_id,
            subscription_plan_id: req.query.subscription_plan_id,
            status: req.query.status,
            platform: req.query.platform,
            search: req.query.search
        };

        let storeSync = null;
        const shouldSync =
            req.query.sync_stores === '1' ||
            req.query.sync_stores === 'true' ||
            req.query.sync_stores === true;

        if (shouldSync) {
            storeSync = await userSubscriptionService.syncAllStoreSubscriptionsFromStore(listFilters);
        }

        const data = await userSubscriptionService.listUserSubscriptions(listFilters);

        res.status(200).json({
            success: true,
            count: data.length,
            data,
            storeSync
        });
    } catch (error) {
        next(error);
    }
};

const getAdminSubscriptionLogs = async (req, res, next) => {
    try {
        const result = await userSubscriptionService.listSubscriptionLogs({
            user_subscription_id: req.query.user_subscription_id,
            user_id: req.query.user_id,
            action: req.query.action,
            page: req.query.page,
            limit: req.query.limit
        });
        res.status(200).json({
            success: true,
            count: result.data.length,
            data: result.data,
            pagination: result.pagination
        });
    } catch (error) {
        next(error);
    }
};

const getAdminSubscriptionLogsById = async (req, res, next) => {
    try {
        const result = await userSubscriptionService.listSubscriptionLogs({
            user_subscription_id: req.params.id,
            page: req.query.page,
            limit: req.query.limit
        });
        res.status(200).json({
            success: true,
            count: result.data.length,
            data: result.data,
            pagination: result.pagination
        });
    } catch (error) {
        next(error);
    }
};

const createAdminUserSubscription = async (req, res, next) => {
    try {
        const data = await userSubscriptionService.createUserSubscription(
            req.body,
            req.user?.id || null
        );
        res.status(201).json({
            success: true,
            message: 'Subscription assigned to user',
            data
        });
    } catch (error) {
        if (
            error.message === 'User not found.' ||
            error.message === 'Subscription plan not found.'
        ) {
            res.status(404);
        }
        next(error);
    }
};

const updateAdminUserSubscriptionExpiry = async (req, res, next) => {
    try {
        const data = await userSubscriptionService.updateExpiry(
            req.params.id,
            req.body,
            req.user?.id || null
        );
        res.status(200).json({
            success: true,
            message: 'Expiry date updated',
            data
        });
    } catch (error) {
        if (error.message === 'User subscription not found') res.status(404);
        next(error);
    }
};

const deactivateAdminUserSubscription = async (req, res, next) => {
    try {
        const data = await userSubscriptionService.deactivateUserSubscription(
            req.params.id,
            req.body,
            req.user?.id || null
        );
        res.status(200).json({
            success: true,
            message: 'Subscription deactivated',
            data
        });
    } catch (error) {
        if (error.message === 'User subscription not found') res.status(404);
        next(error);
    }
};

const cancelAdminUserSubscription = async (req, res, next) => {
    try {
        const result = await userSubscriptionService.cancelUserSubscription(
            req.params.id,
            req.body,
            req.user?.id || null
        );
        let message = 'User subscription cancelled in database.';
        const store = result.store;
        if (store?.action === 'cancelled') {
            message += ' Google Play: renewals stopped (active until expiry).';
        } else if (store?.action === 'manual_required') {
            message += ` App Store: ${store.message}`;
        } else if (store?.error) {
            message += ` Store: ${store.error}`;
        } else if (store?.skipped) {
            message += ' Store: skipped (missing token or not a store subscription).';
        }
        res.status(200).json({
            success: true,
            message,
            data: result.subscription,
            store: result.store
        });
    } catch (error) {
        if (
            error.message === 'User subscription not found' ||
            error.message === 'Subscription was already refunded.'
        ) {
            res.status(404);
        }
        next(error);
    }
};

const refundAdminUserSubscription = async (req, res, next) => {
    try {
        const result = await userSubscriptionService.refundUserSubscription(
            req.params.id,
            req.body,
            req.user?.id || null
        );
        let message = 'Subscription refunded in database.';
        const store = result.store;
        if (store?.action === 'refunded') {
            message += ' Google Play: refund processed.';
        } else if (store?.action === 'manual_required') {
            message += ` App Store: ${store.message}`;
        } else if (store?.error) {
            message += ` Store: ${store.error}`;
        } else if (store?.skipped) {
            message += ' Store: skipped (missing token or not a store subscription).';
        }
        res.status(200).json({
            success: true,
            message,
            data: result.subscription,
            store: result.store
        });
    } catch (error) {
        if (
            error.message === 'User subscription not found' ||
            error.message === 'Subscription was already refunded.'
        ) {
            res.status(404);
        }
        next(error);
    }
};

const getAdminUserSubscriptionStoreSyncs = async (req, res, next) => {
    try {
        const result = await userSubscriptionService.listStoreSyncs({
            user_subscription_id: req.params.id,
            page: req.query.page,
            limit: req.query.limit
        });
        res.status(200).json({
            success: true,
            count: result.data.length,
            data: result.data,
            pagination: result.pagination
        });
    } catch (error) {
        next(error);
    }
};

const syncAdminUserSubscriptionFromStore = async (req, res, next) => {
    try {
        const result = await userSubscriptionService.syncUserSubscriptionFromStore(
            req.params.id,
            req.user?.id || null
        );
        res.status(200).json({
            success: true,
            message: result.message,
            changed: result.changed,
            data: result.subscription,
            store: result.store,
            syncRecord: result.syncRecord,
            console: result.console
        });
    } catch (error) {
        if (error.console && Array.isArray(error.console)) {
            const status = error.message === 'User subscription not found' ? 404 : 400;
            return res.status(status).json({
                success: false,
                message: error.message,
                console: error.console
            });
        }
        if (error.message === 'User subscription not found') {
            res.status(404);
        } else if (
            error.message.includes('not configured') ||
            error.message.includes('required') ||
            error.message.includes('only for') ||
            error.message.includes('Cannot sync')
        ) {
            res.status(400);
        }
        next(error);
    }
};

const deleteAdminUserSubscription = async (req, res, next) => {
    try {
        const data = await userSubscriptionService.deleteUserSubscription(
            req.params.id,
            req.body,
            req.user?.id || null
        );
        res.status(200).json({
            success: true,
            message: 'User subscription deleted',
            data
        });
    } catch (error) {
        if (error.message === 'User subscription not found') res.status(404);
        next(error);
    }
};

module.exports = {
    getAdminUserSubscriptions,
    getAdminUserSubscriptionById,
    getAdminSubscriptionLogs,
    getAdminSubscriptionLogsById,
    createAdminUserSubscription,
    updateAdminUserSubscriptionExpiry,
    deactivateAdminUserSubscription,
    cancelAdminUserSubscription,
    refundAdminUserSubscription,
    deleteAdminUserSubscription,
    syncAdminUserSubscriptionFromStore,
    getAdminUserSubscriptionStoreSyncs
};
