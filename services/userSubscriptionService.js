const { Op } = require('sequelize');
const UserSubscription = require('../models/userSubscriptionModel');
const UserSubscriptionLog = require('../models/userSubscriptionLogModel');
const User = require('../models/userModel');
const Profile = require('../models/profileModel');
const SubscriptionPlan = require('../models/subscriptionPlanModel');
const googlePlayStore = require('./store/googlePlaySubscriptionStoreService');
const appleServer = require('./store/appleAppStoreServerService');
const storeSync = require('./userSubscriptionStoreSyncService');

const { refundSubscriptionPurchase, revokeSubscriptionPurchase } = googlePlayStore;

const runStoreSubscriptionAction = async (row, action, body = {}) => {
    const flagKey = action === 'cancel' ? 'cancel_on_store' : 'refund_on_store';
    if (body[flagKey] === false) {
        return { skipped: true, reason: 'disabled_by_request' };
    }

    const token = row.store_purchase_token ? String(row.store_purchase_token).trim() : '';
    const platform = row.platform;

    if (platform === 'google_play') {
        const playId = row.plan?.play_store_sub_id;
        if (!playId || !token) {
            if (body.require_store === true) {
                throw new Error(
                    'Google Play requires store_purchase_token and plan play_store_sub_id.'
                );
            }
            return { skipped: true, reason: 'missing_play_credentials' };
        }
        if (action === 'cancel') {
            return googlePlayStore.cancelSubscriptionPurchase(playId, token);
        }
        if (action === 'refund') {
            return googlePlayStore.refundSubscriptionPurchase(playId, token);
        }
    }

    if (platform === 'app_store') {
        if (!token) {
            if (body.require_store === true) {
                throw new Error('App Store requires store_purchase_token (original transaction ID).');
            }
            return { skipped: true, reason: 'missing_transaction_id' };
        }
        if (action === 'cancel') {
            return appleServer.cancelSubscriptionPurchase(token);
        }
        if (action === 'refund') {
            return appleServer.refundSubscriptionPurchase(token);
        }
    }

    if (['google_play', 'app_store'].includes(platform) && body.require_store === true) {
        throw new Error(`Store ${action} is not supported for platform: ${platform}`);
    }

    return { skipped: true, reason: 'not_a_store_platform' };
};

const STATUSES = ['trialing', 'active', 'expired', 'cancelled', 'paused'];
const PLATFORMS = ['google_play', 'app_store', 'manual', 'admin'];
const LOG_ACTIONS = [
    'created',
    'expiry_updated',
    'deactivated',
    'cancelled',
    'refunded',
    'deleted',
    'reactivated',
    'store_synced'
];

const subscriptionIncludes = [
    {
        model: User,
        as: 'user',
        attributes: ['id', 'email', 'status'],
        include: [{ model: Profile, as: 'profile', attributes: ['full_name'] }]
    },
    {
        model: SubscriptionPlan,
        as: 'plan',
        attributes: ['id', 'name', 'price', 'currency', 'status', 'play_store_sub_id', 'app_store_sub_id']
    }
];

const formatRow = (row) => {
    const plain = row.get ? row.get({ plain: true }) : row;
    const user = plain.user || {};
    const profile = user.profile || {};
    const plan = plain.plan || {};

    return {
        id: plain.id,
        user_id: plain.user_id,
        subscription_plan_id: plain.subscription_plan_id,
        status: plain.status,
        platform: plain.platform,
        store_purchase_token: plain.store_purchase_token,
        started_at: plain.started_at,
        expires_at: plain.expires_at,
        cancelled_at: plain.cancelled_at || null,
        refunded_at: plain.refunded_at || null,
        deactivated_at: plain.deactivated_at || null,
        auto_renew: plain.auto_renew,
        createdAt: plain.createdAt,
        updatedAt: plain.updatedAt,
        user: {
            id: user.id,
            email: user.email,
            status: user.status,
            full_name: profile.full_name || null
        },
        plan: {
            id: plan.id,
            name: plan.name,
            price: plan.price,
            currency: plan.currency,
            status: plan.status,
            play_store_sub_id: plan.play_store_sub_id || null,
            app_store_sub_id: plan.app_store_sub_id || null
        }
    };
};

const formatLog = (row) => {
    const plain = row.get ? row.get({ plain: true }) : row;
    return {
        id: plain.id,
        user_subscription_id: plain.user_subscription_id,
        user_id: plain.user_id,
        action: plain.action,
        performed_by: plain.performed_by,
        note: plain.note,
        metadata: plain.metadata,
        createdAt: plain.createdAt
    };
};

const appendLog = async ({
    user_subscription_id,
    user_id,
    action,
    performed_by = null,
    note = null,
    metadata = null
}) => {
    if (!LOG_ACTIONS.includes(action)) {
        throw new Error(`Invalid log action: ${action}`);
    }
    const log = await UserSubscriptionLog.create({
        user_subscription_id,
        user_id,
        action,
        performed_by,
        note,
        metadata
    });
    return formatLog(log);
};

const loadSubscription = async (id, transaction) => {
    const row = await UserSubscription.findByPk(id, {
        include: subscriptionIncludes,
        transaction
    });
    if (!row) throw new Error('User subscription not found');
    return row;
};

const syncExpiryStatus = async (row) => {
    if (!row.expires_at || row.status === 'cancelled' || row.refunded_at) return row;
    const exp = new Date(row.expires_at);
    if (exp.getTime() < Date.now() && row.status === 'active') {
        await row.update({ status: 'expired', auto_renew: false });
    }
    return row;
};

const listUserSubscriptions = async (filters = {}) => {
    const where = {};

    if (filters.user_id) where.user_id = filters.user_id;
    if (filters.subscription_plan_id) where.subscription_plan_id = filters.subscription_plan_id;
    if (filters.status) where.status = filters.status;
    if (filters.platform) where.platform = filters.platform;

    if (filters.search) {
        const q = `%${String(filters.search).trim()}%`;
        where[Op.or] = [
            { '$user.email$': { [Op.like]: q } },
            { '$user.profile.full_name$': { [Op.like]: q } },
            { '$plan.name$': { [Op.like]: q } }
        ];
    }

    const rows = await UserSubscription.findAll({
        where,
        include: subscriptionIncludes,
        order: [['createdAt', 'DESC']],
        subQuery: false
    });

    for (const row of rows) {
        await syncExpiryStatus(row);
    }

    return rows.map(formatRow);
};

/** Sync every Play / App Store row (with token) then return summary for list page. */
const syncAllStoreSubscriptionsFromStore = async (filters = {}) => {
    const where = {
        platform: { [Op.in]: ['google_play', 'app_store'] },
        refunded_at: null,
        store_purchase_token: { [Op.and]: [{ [Op.ne]: null }, { [Op.ne]: '' }] }
    };

    if (filters.user_id) where.user_id = filters.user_id;
    if (filters.subscription_plan_id) where.subscription_plan_id = filters.subscription_plan_id;

    const rows = await UserSubscription.findAll({
        where,
        include: subscriptionIncludes,
        order: [['updatedAt', 'DESC']]
    });

    const summary = {
        checked: 0,
        updated: 0,
        unchanged: 0,
        skipped: 0,
        failed: 0,
        errors: [],
        console: []
    };

    const bulkLog = storeSync.createSyncLogger();
    bulkLog.log('▶ Auto sync — user subscriptions list');
    bulkLog.log(`Found ${rows.length} store subscription(s) to check`);

    for (const row of rows) {
        const token = row.store_purchase_token ? String(row.store_purchase_token).trim() : '';
        if (!token) {
            summary.skipped += 1;
            continue;
        }

        summary.checked += 1;
        const label = `${row.user?.email || row.user_id} (${row.platform})`;
        bulkLog.log(`— Syncing ${label}…`);

        try {
            const result = await syncUserSubscriptionFromStore(row.id);
            if (result.changed) {
                summary.updated += 1;
                bulkLog.log(`✓ Updated: ${label}`);
            } else {
                summary.unchanged += 1;
                bulkLog.log(`○ Unchanged: ${label}`);
            }
        } catch (err) {
            summary.failed += 1;
            summary.errors.push({
                id: row.id,
                email: row.user?.email || null,
                platform: row.platform,
                message: err.message
            });
            bulkLog.log(`✗ Failed: ${label} — ${err.message}`);
            if (err.console) {
                summary.console.push(...err.console);
            }
        }
    }

    bulkLog.log(
        `▶ Finished — ${summary.updated} updated, ${summary.unchanged} unchanged, ${summary.failed} failed`
    );
    summary.console = bulkLog.lines;

    return summary;
};

const listSubscriptionLogs = async (filters = {}) => {
    const where = {};
    if (filters.user_subscription_id) where.user_subscription_id = filters.user_subscription_id;
    if (filters.user_id) where.user_id = filters.user_id;
    if (filters.action) where.action = filters.action;

    const limit = Math.min(Math.max(Number(filters.limit) || 10, 1), 50);
    const page = Math.max(Number(filters.page) || 1, 1);
    const offset = (page - 1) * limit;

    const { count, rows } = await UserSubscriptionLog.findAndCountAll({
        where,
        order: [['createdAt', 'DESC']],
        limit,
        offset
    });

    const totalPages = Math.max(Math.ceil(count / limit), 1);

    return {
        data: rows.map(formatLog),
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

const createUserSubscription = async (body, performedBy = null) => {
    const user_id = body.user_id != null ? String(body.user_id).trim() : '';
    const subscription_plan_id =
        body.subscription_plan_id != null ? String(body.subscription_plan_id).trim() : '';

    if (!user_id) throw new Error('user_id is required.');
    if (!subscription_plan_id) throw new Error('subscription_plan_id is required.');

    const user = await User.findByPk(user_id);
    if (!user) throw new Error('User not found.');

    const plan = await SubscriptionPlan.findByPk(subscription_plan_id);
    if (!plan) throw new Error('Subscription plan not found.');

    const status = body.status != null ? String(body.status).trim().toLowerCase() : 'active';
    if (!STATUSES.includes(status)) {
        throw new Error(`Status must be one of: ${STATUSES.join(', ')}`);
    }

    const platform = body.platform != null ? String(body.platform).trim().toLowerCase() : 'admin';
    if (!PLATFORMS.includes(platform)) {
        throw new Error(`Platform must be one of: ${PLATFORMS.join(', ')}`);
    }

    const started_at = body.started_at ? new Date(body.started_at) : new Date();
    if (Number.isNaN(started_at.getTime())) {
        throw new Error('started_at is invalid.');
    }

    let expires_at = null;
    if (body.expires_at) {
        expires_at = new Date(body.expires_at);
        if (Number.isNaN(expires_at.getTime())) throw new Error('expires_at is invalid.');
    }

    const row = await UserSubscription.create({
        user_id,
        subscription_plan_id,
        status,
        platform,
        store_purchase_token: body.store_purchase_token
            ? String(body.store_purchase_token).trim()
            : null,
        started_at,
        expires_at,
        auto_renew: body.auto_renew !== false && body.auto_renew !== 'false',
        cancelled_at: status === 'cancelled' ? new Date() : null
    });

    await appendLog({
        user_subscription_id: row.id,
        user_id,
        action: 'created',
        performed_by: performedBy,
        note: body.note || null,
        metadata: {
            subscription_plan_id,
            status,
            platform,
            expires_at: expires_at ? expires_at.toISOString() : null
        }
    });

    return getUserSubscriptionById(row.id);
};

const getUserSubscriptionById = async (id) => {
    const row = await UserSubscription.findByPk(id, { include: subscriptionIncludes });
    if (!row) return null;
    await syncExpiryStatus(row);
    return formatRow(row);
};

const syncUserSubscriptionFromStore = async (id, performedBy = null) => {
    const row = await loadSubscription(id);

    if (row.refunded_at) {
        throw new Error('Cannot sync a refunded subscription from the store.');
    }

    if (!['google_play', 'app_store'].includes(row.platform)) {
        throw new Error('Store sync is only for Google Play or App Store subscriptions.');
    }

    const logger = storeSync.createSyncLogger();
    logger.log('▶ Store sync started');
    logger.log(`User subscription: ${row.id}`);
    logger.log(
        `DB now → status: ${row.status}, expires: ${row.expires_at ? new Date(row.expires_at).toISOString() : '—'}, auto_renew: ${row.auto_renew}`
    );

    try {
        const snapshot = await storeSync.fetchStoreSnapshot(row, logger);
        logger.log('Comparing store data with database…');
        const built = storeSync.buildUpdatesFromSnapshot(row, snapshot);
        const updates = built.updates;

        if (!Object.keys(updates).length) {
            logger.log('✓ No changes needed — DB already matches store');
            const syncRecord = await storeSync.recordStoreSync({
                row,
                sync_type: 'pull',
                status: 'no_change',
                message: 'Already up to date with the store.',
                snapshot,
                previous: built.previous,
                performed_by: performedBy,
                console_log: logger.lines
            });
            return {
                subscription: await getUserSubscriptionById(id),
                store: snapshot,
                changed: false,
                message: 'Already up to date with the store.',
                syncRecord,
                console: logger.lines
            };
        }

        logger.log(`Updating user_subscriptions (${Object.keys(updates).join(', ')})…`);
        await row.update(updates);
        logger.log('✓ Database updated from store');
        logger.log('▶ Store sync finished');

        const syncRecord = await storeSync.recordStoreSync({
            row,
            sync_type: 'pull',
            status: 'success',
            message: 'User subscription updated from store.',
            snapshot,
            previous: built.previous,
            applied_updates: updates,
            user_updated: true,
            performed_by: performedBy,
            console_log: logger.lines
        });

        await appendLog({
            user_subscription_id: row.id,
            user_id: row.user_id,
            action: 'store_synced',
            performed_by: performedBy,
            note: `Synced from ${row.platform === 'google_play' ? 'Google Play' : 'App Store'}`,
            metadata: {
                platform: row.platform,
                previous: built.previous,
                updates: {
                    status: row.status,
                    expires_at: row.expires_at ? new Date(row.expires_at).toISOString() : null,
                    auto_renew: row.auto_renew,
                    cancelled_at: row.cancelled_at ? new Date(row.cancelled_at).toISOString() : null
                },
                store_sync_id: syncRecord.id
            }
        });

        return {
            subscription: await getUserSubscriptionById(id),
            store: snapshot,
            changed: true,
            message: 'Subscription updated from store.',
            syncRecord,
            console: logger.lines
        };
    } catch (err) {
        logger.log(`✗ Sync failed: ${err.message}`);
        const { previous } = storeSync.buildUpdatesFromSnapshot(row, {});
        await storeSync.recordStoreSync({
            row,
            sync_type: 'pull',
            status: 'failed',
            message: 'Store sync failed.',
            previous,
            error_detail: err.message,
            performed_by: performedBy,
            console_log: logger.lines
        });
        const wrapped = new Error(err.message);
        wrapped.console = logger.lines;
        throw wrapped;
    }
};

const updateExpiry = async (id, body, performedBy = null) => {
    const row = await loadSubscription(id);
    const previous = row.expires_at ? new Date(row.expires_at).toISOString() : null;

    if (body.expires_at === null || body.expires_at === '') {
        await row.update({ expires_at: null });
    } else {
        const expires_at = new Date(body.expires_at);
        if (Number.isNaN(expires_at.getTime())) throw new Error('expires_at is invalid.');
        const updates = { expires_at };
        if (expires_at.getTime() < Date.now() && row.status === 'active') {
            updates.status = 'expired';
            updates.auto_renew = false;
        } else if (expires_at.getTime() >= Date.now() && row.status === 'expired') {
            updates.status = 'active';
        }
        await row.update(updates);
    }

    await appendLog({
        user_subscription_id: row.id,
        user_id: row.user_id,
        action: 'expiry_updated',
        performed_by: performedBy,
        note: body.note || null,
        metadata: {
            previous_expires_at: previous,
            expires_at: row.expires_at ? new Date(row.expires_at).toISOString() : null
        }
    });

    return getUserSubscriptionById(id);
};

const deactivateUserSubscription = async (id, body = {}, performedBy = null) => {
    const row = await loadSubscription(id);
    if (row.refunded_at) {
        throw new Error('Subscription was already refunded.');
    }

    let storeResult = null;
    const playId = row.plan?.play_store_sub_id;
    const token = row.store_purchase_token;

    if (
        body.revoke_on_store !== false &&
        row.platform === 'google_play' &&
        playId &&
        token
    ) {
        try {
            storeResult = await revokeSubscriptionPurchase(playId, token);
        } catch (err) {
            if (body.require_store !== true) {
                storeResult = { error: err.message, skipped: true };
            } else {
                throw err;
            }
        }
    }

    await row.update({
        status: 'paused',
        auto_renew: false,
        deactivated_at: new Date()
    });

    await appendLog({
        user_subscription_id: row.id,
        user_id: row.user_id,
        action: 'deactivated',
        performed_by: performedBy,
        note: body.note || null,
        metadata: { store: storeResult }
    });

    return getUserSubscriptionById(id);
};

const cancelUserSubscription = async (id, body = {}, performedBy = null) => {
    const row = await loadSubscription(id);
    if (row.refunded_at) {
        throw new Error('Subscription was already refunded.');
    }

    const previous = {
        status: row.status,
        expires_at: row.expires_at ? new Date(row.expires_at).toISOString() : null,
        auto_renew: row.auto_renew
    };

    let storeResult = null;
    let syncRecord = null;
    try {
        storeResult = await runStoreSubscriptionAction(row, 'cancel', body);
        syncRecord = await storeSync.recordStoreSync({
            row,
            sync_type: 'cancel',
            status: storeResult?.action === 'cancelled' ? 'success' : 'manual_required',
            message: storeResult?.message || 'Cancel processed on store.',
            store_action_result: storeResult,
            previous,
            performed_by: performedBy
        });
    } catch (err) {
        if (body.require_store === true) throw err;
        storeResult = { error: err.message, skipped: true };
        syncRecord = await storeSync.recordStoreSync({
            row,
            sync_type: 'cancel',
            status: 'failed',
            message: 'Store cancel failed.',
            previous,
            error_detail: err.message,
            store_action_result: storeResult,
            performed_by: performedBy
        });
    }

    await row.update({
        status: 'cancelled',
        cancelled_at: new Date(),
        auto_renew: false
    });

    await appendLog({
        user_subscription_id: row.id,
        user_id: row.user_id,
        action: 'cancelled',
        performed_by: performedBy,
        note: body.note || null,
        metadata: { store: storeResult, store_sync_id: syncRecord?.id }
    });

    return {
        subscription: await getUserSubscriptionById(id),
        store: storeResult,
        syncRecord,
        console: syncRecord?.console
    };
};

const refundUserSubscription = async (id, body = {}, performedBy = null) => {
    const row = await loadSubscription(id);
    if (row.refunded_at) {
        throw new Error('Subscription was already refunded.');
    }

    const previous = {
        status: row.status,
        expires_at: row.expires_at ? new Date(row.expires_at).toISOString() : null,
        auto_renew: row.auto_renew,
        refunded_at: row.refunded_at
    };

    let storeResult = null;
    let syncRecord = null;
    try {
        storeResult = await runStoreSubscriptionAction(row, 'refund', body);
        syncRecord = await storeSync.recordStoreSync({
            row,
            sync_type: 'refund',
            status: storeResult?.action === 'refunded' ? 'success' : 'manual_required',
            message: storeResult?.message || 'Refund processed on store.',
            store_action_result: storeResult,
            previous,
            performed_by: performedBy
        });
    } catch (err) {
        if (body.require_store === true) throw err;
        storeResult = { error: err.message, skipped: true };
        syncRecord = await storeSync.recordStoreSync({
            row,
            sync_type: 'refund',
            status: 'failed',
            message: 'Store refund failed.',
            previous,
            error_detail: err.message,
            store_action_result: storeResult,
            performed_by: performedBy
        });
    }

    const now = new Date();
    await row.update({
        status: 'cancelled',
        cancelled_at: row.cancelled_at || now,
        refunded_at: now,
        auto_renew: false
    });

    await appendLog({
        user_subscription_id: row.id,
        user_id: row.user_id,
        action: 'refunded',
        performed_by: performedBy,
        note: body.note || null,
        metadata: { store: storeResult, store_sync_id: syncRecord?.id }
    });

    return {
        subscription: await getUserSubscriptionById(id),
        store: storeResult,
        syncRecord,
        console: syncRecord?.console
    };
};

const deleteUserSubscription = async (id, body = {}, performedBy = null) => {
    const row = await loadSubscription(id);
    const snapshot = formatRow(row);

    await appendLog({
        user_subscription_id: row.id,
        user_id: row.user_id,
        action: 'deleted',
        performed_by: performedBy,
        note: body.note || null,
        metadata: { snapshot }
    });

    await row.destroy();
    return { deleted: true, id, snapshot };
};

module.exports = {
    listUserSubscriptions,
    listSubscriptionLogs,
    createUserSubscription,
    getUserSubscriptionById,
    updateExpiry,
    deactivateUserSubscription,
    cancelUserSubscription,
    refundUserSubscription,
    deleteUserSubscription,
    syncUserSubscriptionFromStore,
    syncAllStoreSubscriptionsFromStore,
    listStoreSyncs: storeSync.listStoreSyncs,
    STATUSES,
    PLATFORMS,
    LOG_ACTIONS
};
