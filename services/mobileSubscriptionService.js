const { Op } = require('sequelize');
const { sequelize } = require('../database/db');
const SubscriptionPlan = require('../models/subscriptionPlanModel');
const UserSubscription = require('../models/userSubscriptionModel');
const UserSubscriptionLog = require('../models/userSubscriptionLogModel');
const googlePlayStore = require('./store/googlePlaySubscriptionStoreService');
const appleServer = require('./store/appleAppStoreServerService');
const storeSync = require('./userSubscriptionStoreSyncService');
const { isGooglePlayConfigured, isAppleAppStoreConfigured } = require('../config/storeProvisioning');

const PUBLIC_PLAN_ATTRS = [
    'id',
    'name',
    'description',
    'free_trials',
    'price',
    'currency',
    'features',
    'play_store_sub_id',
    'app_store_sub_id'
];

const planInclude = {
    model: SubscriptionPlan,
    as: 'plan',
    attributes: PUBLIC_PLAN_ATTRS
};

const listPublicPlans = async (filters = {}) => {
    const limit = Math.min(Math.max(Number(filters.limit) || 10, 1), 50);
    const page = Math.max(Number(filters.page) || 1, 1);
    const offset = (page - 1) * limit;

    const { count, rows } = await SubscriptionPlan.findAndCountAll({
        where: { status: 'active' },
        attributes: PUBLIC_PLAN_ATTRS,
        order: [['price', 'ASC'], ['name', 'ASC']],
        limit,
        offset
    });

    const totalPages = Math.max(Math.ceil(count / limit), 1);

    return {
        data: rows,
        pagination: {
            page,
            limit,
            total: count,
            totalPages,
            hasPrev: page > 1,
            hasNext: page < totalPages
        }
    };
};

const syncExpiryStatus = async (row) => {
    if (!row.expires_at || row.status === 'cancelled' || row.refunded_at) return row;
    const exp = new Date(row.expires_at);
    if (exp.getTime() < Date.now() && ['active', 'trialing'].includes(row.status)) {
        await row.update({ status: 'expired', auto_renew: false });
    }
    return row;
};

const formatPublicSubscription = (row) => {
    const j = row.get ? row.get({ plain: true }) : row;
    return {
        id: j.id,
        subscription_plan_id: j.subscription_plan_id,
        status: j.status,
        platform: j.platform,
        started_at: j.started_at,
        expires_at: j.expires_at,
        cancelled_at: j.cancelled_at,
        auto_renew: j.auto_renew,
        is_active: ['active', 'trialing'].includes(j.status) &&
            (!j.expires_at || new Date(j.expires_at).getTime() > Date.now()),
        plan: j.plan || null
    };
};

const getMySubscription = async (userId) => {
    const rows = await UserSubscription.findAll({
        where: { user_id: userId },
        include: [planInclude],
        order: [['createdAt', 'DESC']],
        limit: 10
    });

    for (const row of rows) {
        await syncExpiryStatus(row);
    }

    const active = rows.find((r) => {
        const j = r.get ? r.get({ plain: true }) : r;
        return ['active', 'trialing'].includes(j.status) &&
            (!j.expires_at || new Date(j.expires_at).getTime() > Date.now());
    });

    return {
        is_premium: !!active,
        subscription: active ? formatPublicSubscription(active) : null,
        history: rows.map(formatPublicSubscription)
    };
};

const appendLog = async ({ user_subscription_id, user_id, action, note = null, metadata = null }) => {
    await UserSubscriptionLog.create({
        user_subscription_id,
        user_id,
        action,
        performed_by: user_id,
        note,
        metadata
    });
};

const assertProductMatch = (plan, platform, snapshot) => {
    const storeProductId = snapshot.productId ? String(snapshot.productId).trim() : '';
    if (platform === 'google_play') {
        const expected = plan.play_store_sub_id ? String(plan.play_store_sub_id).trim() : '';
        if (expected && storeProductId && expected !== storeProductId) {
            throw new Error('Purchase product does not match this plan on Google Play.');
        }
    }
    if (platform === 'app_store') {
        const expected = plan.app_store_sub_id ? String(plan.app_store_sub_id).trim() : '';
        if (expected && storeProductId && expected !== storeProductId) {
            throw new Error('Purchase product does not match this plan on the App Store.');
        }
    }
};

const verifyStorePurchase = async (platform, plan, purchaseToken) => {
    const token = purchaseToken != null ? String(purchaseToken).trim() : '';
    if (!token) {
        throw new Error('purchase_token is required');
    }

    if (platform === 'google_play') {
        if (!isGooglePlayConfigured()) {
            throw new Error('Google Play verification is not configured on the server.');
        }
        if (!plan.play_store_sub_id) {
            throw new Error('This plan is not linked to a Google Play subscription ID.');
        }
        const snapshot = await googlePlayStore.getSubscriptionPurchaseStatus(plan.play_store_sub_id, token);
        assertProductMatch(plan, platform, snapshot);
        return snapshot;
    }

    if (platform === 'app_store') {
        if (!isAppleAppStoreConfigured()) {
            throw new Error('App Store verification is not configured on the server.');
        }
        if (!plan.app_store_sub_id) {
            throw new Error('This plan is not linked to an App Store subscription ID.');
        }
        const snapshot = await appleServer.getSubscriptionPurchaseStatus(token);
        assertProductMatch(plan, platform, snapshot);
        return snapshot;
    }

    throw new Error('platform must be google_play or app_store');
};

const expireOtherActiveSubscriptions = async (userId, keepId, transaction) => {
    await UserSubscription.update(
        { status: 'expired', auto_renew: false },
        {
            where: {
                user_id: userId,
                id: { [Op.ne]: keepId },
                status: { [Op.in]: ['active', 'trialing'] }
            },
            transaction
        }
    );
};

const upsertFromStore = async (userId, plan, platform, purchaseToken, snapshot) => {
    const token = String(purchaseToken).trim();

    let row = await UserSubscription.findOne({
        where: {
            user_id: userId,
            store_purchase_token: token,
            platform
        },
        include: [planInclude]
    });

    if (!row) {
        row = await UserSubscription.findOne({
            where: {
                user_id: userId,
                subscription_plan_id: plan.id,
                platform
            },
            include: [planInclude],
            order: [['createdAt', 'DESC']]
        });
    }

    const baseFields = {
        user_id: userId,
        subscription_plan_id: plan.id,
        platform,
        store_purchase_token: token,
        status: snapshot.status || 'active',
        started_at: snapshot.startedAt ? new Date(snapshot.startedAt) : new Date(),
        expires_at: snapshot.expiresAt ? new Date(snapshot.expiresAt) : null,
        auto_renew: snapshot.autoRenew !== false,
        cancelled_at: snapshot.cancelledAt ? new Date(snapshot.cancelledAt) : null
    };

    const t = await sequelize.transaction();
    try {
        let created = false;
        if (row) {
            const built = storeSync.buildUpdatesFromSnapshot(row, snapshot);
            const patch = { ...baseFields, ...built.updates, subscription_plan_id: plan.id };
            await row.update(patch, { transaction: t });
        } else {
            row = await UserSubscription.create(baseFields, { transaction: t });
            created = true;
        }

        await expireOtherActiveSubscriptions(userId, row.id, t);

        await appendLog({
            user_subscription_id: row.id,
            user_id: userId,
            action: created ? 'created' : 'store_synced',
            note: created ? 'Subscribed via mobile app' : 'Subscription refreshed via mobile app',
            metadata: {
                platform,
                subscription_plan_id: plan.id,
                store_status: snapshot.status,
                expires_at: baseFields.expires_at ? baseFields.expires_at.toISOString() : null
            }
        });

        await t.commit();
    } catch (err) {
        await t.rollback();
        throw err;
    }

    const fresh = await UserSubscription.findByPk(row.id, { include: [planInclude] });
    await syncExpiryStatus(fresh);
    return formatPublicSubscription(fresh);
};

const subscribeUser = async (userId, body) => {
    const subscription_plan_id = body.subscription_plan_id != null
        ? String(body.subscription_plan_id).trim()
        : '';
    if (!subscription_plan_id) {
        throw new Error('subscription_plan_id is required');
    }

    const platform = body.platform != null ? String(body.platform).trim().toLowerCase() : '';
    if (!['google_play', 'app_store'].includes(platform)) {
        throw new Error('platform must be google_play or app_store');
    }

    const purchaseToken = body.purchase_token || body.store_purchase_token;
    const plan = await SubscriptionPlan.findOne({
        where: { id: subscription_plan_id, status: 'active' }
    });
    if (!plan) {
        throw new Error('Subscription plan not found or not available');
    }

    const snapshot = await verifyStorePurchase(platform, plan, purchaseToken);
    const subscription = await upsertFromStore(userId, plan, platform, purchaseToken, snapshot);

    return {
        is_premium: subscription.is_active,
        subscription
    };
};

const restoreUserSubscription = async (userId, body) => subscribeUser(userId, body);

module.exports = {
    listPublicPlans,
    getMySubscription,
    subscribeUser,
    restoreUserSubscription
};
