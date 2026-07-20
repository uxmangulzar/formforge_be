const SubscriptionPlan = require('../models/subscriptionPlanModel');
const { validatePayload } = require('./subscriptionPlanService');
const {
    isGooglePlayConfigured,
    isAppleAppStoreConfigured,
    getStoreProvisioningStatus
} = require('../config/storeProvisioning');
const {
    slugifyProductId,
    toGoogleProductId,
    toAppleProductId
} = require('../utils/productId');
const googlePlayStore = require('./store/googlePlaySubscriptionStoreService');
const appleAppStore = require('./store/appleAppStoreConnectService');

const resolveProductSlug = (body) => {
    const custom = body.product_id != null ? String(body.product_id).trim() : '';
    if (custom) return custom;
    return slugifyProductId(body.name);
};

const createSubscriptionPlanOnStores = async (body) => {
    const status = getStoreProvisioningStatus();
    if (!status.googlePlay.configured && !status.appleAppStore.configured) {
        throw new Error(
            'Store APIs are not configured. Add Google and/or Apple credentials to .env (see .env.example).'
        );
    }

    const slug = resolveProductSlug(body);
    const googleProductId = toGoogleProductId(slug);
    const appleProductId = toAppleProductId(slug);
    const billingPeriod = body.billing_period || process.env.DEFAULT_SUBSCRIPTION_BILLING_PERIOD || 'P1M';

    const storeResults = {
        googlePlay: null,
        appleAppStore: null,
        errors: []
    };

    if (isGooglePlayConfigured()) {
        try {
            storeResults.googlePlay = await googlePlayStore.createSubscription({
                productId: googleProductId,
                title: body.name,
                description: body.description,
                price: body.price,
                currency: body.currency || 'USD',
                billingPeriod
            });
        } catch (err) {
            storeResults.errors.push(`Google Play: ${err.message}`);
        }
    }

    if (isAppleAppStoreConfigured()) {
        try {
            storeResults.appleAppStore = await appleAppStore.createSubscription({
                productId: appleProductId,
                name: body.name,
                description: body.description,
                price: body.price,
                billingPeriod
            });
        } catch (err) {
            storeResults.errors.push(`App Store: ${err.message}`);
        }
    }

    const playId = storeResults.googlePlay?.productId || null;
    const appleId = storeResults.appleAppStore?.productId || null;

    if (!playId && !appleId) {
        throw new Error(storeResults.errors.join(' | ') || 'Failed to create subscription on any store.');
    }

    const payload = validatePayload({
        ...body,
        play_store_sub_id: playId || body.play_store_sub_id,
        app_store_sub_id: appleId || body.app_store_sub_id
    });

    const plan = await SubscriptionPlan.create(payload);

    return {
        plan,
        storeResults,
        warnings:
            storeResults.errors.length > 0
                ? storeResults.errors
                : [
                      'Products may stay in DRAFT on stores until you complete pricing/review in Play Console & App Store Connect.'
                  ]
    };
};

module.exports = {
    createSubscriptionPlanOnStores,
    getStoreProvisioningStatus
};
