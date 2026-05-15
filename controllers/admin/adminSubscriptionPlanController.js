const subscriptionPlanService = require('../../services/subscriptionPlanService');
const subscriptionStoreProvisionService = require('../../services/subscriptionStoreProvisionService');
const googlePlayStore = require('../../services/store/googlePlaySubscriptionStoreService');
const appleAppStore = require('../../services/store/appleAppStoreConnectService');
const { isGooglePlayConfigured, isAppleAppStoreConfigured } = require('../../config/storeProvisioning');

const getAdminSubscriptionPlans = async (req, res, next) => {
    try {
        const data = await subscriptionPlanService.listSubscriptionPlans();
        res.status(200).json({
            success: true,
            count: data.length,
            data
        });
    } catch (error) {
        next(error);
    }
};

const getAdminSubscriptionPlanById = async (req, res, next) => {
    try {
        const data = await subscriptionPlanService.getSubscriptionPlanById(req.params.id);
        if (!data) {
            res.status(404);
            throw new Error('Subscription plan not found');
        }
        res.status(200).json({ success: true, data });
    } catch (error) {
        next(error);
    }
};

const getAdminStoreProvisioningStatus = async (req, res, next) => {
    try {
        const status = subscriptionStoreProvisionService.getStoreProvisioningStatus();
        res.status(200).json({ success: true, data: status });
    } catch (error) {
        next(error);
    }
};

const createAdminSubscriptionPlan = async (req, res, next) => {
    try {
        if (req.body.setup_mode === 'auto') {
            const result = await subscriptionStoreProvisionService.createSubscriptionPlanOnStores(req.body);
            return res.status(201).json({
                success: true,
                message: 'Subscription plan created on store(s) and saved',
                data: result.plan,
                stores: result.storeResults,
                warnings: result.warnings
            });
        }

        const data = await subscriptionPlanService.createSubscriptionPlan(req.body);
        res.status(201).json({
            success: true,
            message: 'Subscription plan created',
            data
        });
    } catch (error) {
        if (
            error.message?.includes('not configured') ||
            error.message?.includes('Google Play') ||
            error.message?.includes('App Store')
        ) {
            res.status(503);
        }
        next(error);
    }
};

const activateAdminSubscriptionPlanOnGooglePlay = async (req, res, next) => {
    try {
        if (!isGooglePlayConfigured()) {
            res.status(503);
            throw new Error('Google Play is not configured in .env');
        }

        const plan = await subscriptionPlanService.getSubscriptionPlanById(req.params.id);
        if (!plan) {
            res.status(404);
            throw new Error('Subscription plan not found');
        }

        if (!plan.play_store_sub_id) {
            res.status(400);
            throw new Error('This plan has no Play Store product ID saved.');
        }

        const activation = await googlePlayStore.activateAllDraftBasePlans(plan.play_store_sub_id);

        res.status(200).json({
            success: true,
            message: 'Base plan(s) activated on Google Play',
            data: {
                planId: plan.id,
                planName: plan.name,
                playStoreProductId: plan.play_store_sub_id,
                activation
            }
        });
    } catch (error) {
        if (error.message === 'Subscription plan not found') {
            res.status(404);
        }
        next(error);
    }
};

const verifyAdminSubscriptionPlanOnGooglePlay = async (req, res, next) => {
    try {
        if (!isGooglePlayConfigured()) {
            res.status(503);
            throw new Error('Google Play is not configured in .env');
        }

        const plan = await subscriptionPlanService.getSubscriptionPlanById(req.params.id);
        if (!plan) {
            res.status(404);
            throw new Error('Subscription plan not found');
        }

        if (!plan.play_store_sub_id) {
            res.status(400);
            throw new Error('This plan has no Play Store product ID saved.');
        }

        const play = await googlePlayStore.verifySubscription(plan.play_store_sub_id);

        res.status(200).json({
            success: true,
            message: play.exists
                ? 'Product found on Google Play'
                : 'Product not found on Google Play',
            data: {
                planId: plan.id,
                planName: plan.name,
                playStoreProductId: plan.play_store_sub_id,
                googlePlay: play
            }
        });
    } catch (error) {
        if (error.message === 'Subscription plan not found') {
            res.status(404);
        }
        next(error);
    }
};

const completeAdminSubscriptionPlanAppStoreMetadata = async (req, res, next) => {
    try {
        if (!isAppleAppStoreConfigured()) {
            res.status(503);
            throw new Error('Apple App Store Connect is not configured in .env');
        }

        const plan = await subscriptionPlanService.getSubscriptionPlanById(req.params.id);
        if (!plan) {
            res.status(404);
            throw new Error('Subscription plan not found');
        }

        if (!plan.app_store_sub_id) {
            res.status(400);
            throw new Error('This plan has no App Store product ID saved.');
        }

        const verified = await appleAppStore.verifySubscription(plan.app_store_sub_id);
        if (!verified.exists || !verified.subscriptionId) {
            res.status(404);
            throw new Error('Subscription not found on App Store Connect.');
        }

        const metadata = await appleAppStore.completeSubscriptionMetadata({
            subscriptionId: verified.subscriptionId,
            name: plan.name,
            description: plan.description,
            price: plan.price
        });

        const apple = await appleAppStore.verifySubscription(plan.app_store_sub_id);

        res.status(200).json({
            success: true,
            message:
                metadata.errors?.length > 0
                    ? 'App Store metadata partially completed (see steps and errors)'
                    : 'App Store metadata completed',
            data: {
                planId: plan.id,
                planName: plan.name,
                appStoreProductId: plan.app_store_sub_id,
                metadata,
                appleAppStore: apple
            }
        });
    } catch (error) {
        if (error.message === 'Subscription plan not found') {
            res.status(404);
        }
        next(error);
    }
};

const verifyAdminSubscriptionPlanOnAppStore = async (req, res, next) => {
    try {
        if (!isAppleAppStoreConfigured()) {
            res.status(503);
            throw new Error('Apple App Store Connect is not configured in .env');
        }

        const plan = await subscriptionPlanService.getSubscriptionPlanById(req.params.id);
        if (!plan) {
            res.status(404);
            throw new Error('Subscription plan not found');
        }

        if (!plan.app_store_sub_id) {
            res.status(400);
            throw new Error('This plan has no App Store product ID saved.');
        }

        const apple = await appleAppStore.verifySubscription(plan.app_store_sub_id);

        res.status(200).json({
            success: true,
            message: apple.exists
                ? 'Product found on App Store Connect'
                : 'Product not found on App Store Connect',
            data: {
                planId: plan.id,
                planName: plan.name,
                appStoreProductId: plan.app_store_sub_id,
                appleAppStore: apple
            }
        });
    } catch (error) {
        if (error.message === 'Subscription plan not found') {
            res.status(404);
        }
        next(error);
    }
};

const updateAdminSubscriptionPlan = async (req, res, next) => {
    try {
        const data = await subscriptionPlanService.updateSubscriptionPlan(req.params.id, req.body);
        res.status(200).json({
            success: true,
            message: 'Subscription plan updated',
            data
        });
    } catch (error) {
        if (error.message === 'Subscription plan not found') {
            res.status(404);
        }
        next(error);
    }
};

const deleteAdminSubscriptionPlan = async (req, res, next) => {
    try {
        const plan = await subscriptionPlanService.getSubscriptionPlanById(req.params.id);
        if (!plan) {
            res.status(404);
            throw new Error('Subscription plan not found');
        }

        let googlePlay = null;
        if (plan.play_store_sub_id && isGooglePlayConfigured()) {
            try {
                googlePlay = await googlePlayStore.removeSubscriptionFromPlay(plan.play_store_sub_id);
            } catch (err) {
                googlePlay = { error: err.message };
            }
        }

        let appStore = null;
        if (plan.app_store_sub_id && isAppleAppStoreConfigured()) {
            try {
                appStore = await appleAppStore.removeSubscriptionFromAppStore(plan.app_store_sub_id);
            } catch (err) {
                appStore = { error: err.message };
            }
        }

        const playStoreOk =
            !plan.play_store_sub_id ||
            !isGooglePlayConfigured() ||
            googlePlay?.skipped ||
            googlePlay?.subscriptionDeleted ||
            googlePlay?.subscriptionDeactivated ||
            googlePlay?.subscriptionArchived;
        const appStoreOk =
            !plan.app_store_sub_id ||
            !isAppleAppStoreConfigured() ||
            appStore?.skipped ||
            appStore?.subscriptionDeleted ||
            appStore?.subscriptionDeactivated;

        await subscriptionPlanService.deleteSubscriptionPlan(req.params.id);

        const playDeleted = googlePlay?.subscriptionDeleted;
        const playDeactivated = googlePlay?.subscriptionDeactivated;
        const playArchived = googlePlay?.subscriptionArchived;
        const appleDeleted = appStore?.subscriptionDeleted;
        const appleRemovedFromSale = appStore?.subscriptionRemovedFromSale;

        let message = 'Stores cleaned up, then plan removed from database.';
        if (googlePlay?.skipped) {
            message += ' Google Play: not found (already removed).';
        } else if (googlePlay?.error) {
            message += ` Google Play error: ${googlePlay.error}`;
        } else if (playDeleted) {
            message += ' Google Play: fully deleted.';
        } else if (playDeactivated || playArchived) {
            message += ' Google Play: deactivated/archived (full delete blocked for published products).';
        } else if (plan.play_store_sub_id && isGooglePlayConfigured()) {
            message += ' Google Play: cleanup attempted — see warnings.';
        }

        if (appStore?.skipped) {
            message += ' App Store: not found (already removed).';
        } else if (appStore?.error) {
            message += ` App Store error: ${appStore.error}`;
        } else if (appleDeleted) {
            message += ' App Store: fully deleted.';
        } else if (appleRemovedFromSale) {
            message += ' App Store: removed from sale (all territories).';
        } else if (plan.app_store_sub_id && isAppleAppStoreConfigured()) {
            const appleWarn = (appStore?.warnings || []).join(' ');
            message += appleWarn
                ? ` App Store: ${appleWarn}`
                : ` App Store: could not delete or deactivate (state: ${appStore?.state || 'unknown'}).`;
        }

        if (
            (plan.play_store_sub_id && isGooglePlayConfigured() && !playStoreOk) ||
            (plan.app_store_sub_id && isAppleAppStoreConfigured() && !appStoreOk)
        ) {
            message += ' Some store cleanup failed — check warnings; DB record was still deleted.';
        }

        res.status(200).json({
            success: true,
            message,
            googlePlay,
            appStore
        });
    } catch (error) {
        if (error.message === 'Subscription plan not found') {
            res.status(404);
        }
        next(error);
    }
};

module.exports = {
    getAdminSubscriptionPlans,
    getAdminSubscriptionPlanById,
    getAdminStoreProvisioningStatus,
    verifyAdminSubscriptionPlanOnGooglePlay,
    verifyAdminSubscriptionPlanOnAppStore,
    completeAdminSubscriptionPlanAppStoreMetadata,
    activateAdminSubscriptionPlanOnGooglePlay,
    createAdminSubscriptionPlan,
    updateAdminSubscriptionPlan,
    deleteAdminSubscriptionPlan
};
