const UserSubscriptionStoreSync = require('../models/userSubscriptionStoreSyncModel');
const googlePlayStore = require('./store/googlePlaySubscriptionStoreService');
const appleServer = require('./store/appleAppStoreServerService');
const { isGooglePlayConfigured, isAppleAppStoreConfigured } = require('../config/storeProvisioning');

const syncTime = () =>
    new Date().toLocaleTimeString('en-GB', { hour12: false, hour: '2-digit', minute: '2-digit', second: '2-digit' });

/** Step-by-step log for admin console UI + server terminal. */
const createSyncLogger = () => {
    const lines = [];
    return {
        lines,
        log(message) {
            const line = `[${syncTime()}] ${message}`;
            lines.push(line);
            console.log('[Admin Store Sync]', line);
            return line;
        }
    };
};

const snapshotSummary = (snapshot) => {
    if (!snapshot || typeof snapshot !== 'object') return {};
    return {
        store_status: snapshot.status || null,
        store_expires_at: snapshot.expiresAt ? new Date(snapshot.expiresAt) : null,
        store_auto_renew: snapshot.autoRenew != null ? Boolean(snapshot.autoRenew) : null,
        store_product_id: snapshot.productId || null
    };
};

const buildConsoleLines = ({ platform, sync_type, status, message, snapshot, previous, applied_updates, error_detail }) => {
    const storeLabel = platform === 'google_play' ? 'Google Play' : 'App Store';
    const lines = [`[${sync_type}] ${storeLabel}`];

    if (error_detail) {
        lines.push(`ERROR: ${error_detail}`);
        return lines;
    }

    if (snapshot) {
        lines.push(
            `Store → status: ${snapshot.status || '—'}, expires: ${
                snapshot.expiresAt ? new Date(snapshot.expiresAt).toISOString() : '—'
            }, auto_renew: ${snapshot.autoRenew != null ? snapshot.autoRenew : '—'}`
        );
        if (snapshot.environment) lines.push(`Environment: ${snapshot.environment}`);
        if (snapshot.apiVersion) lines.push(`API: ${snapshot.apiVersion}`);
    }

    if (previous) {
        lines.push(
            `DB (before) → status: ${previous.status}, expires: ${previous.expires_at || '—'}, auto_renew: ${previous.auto_renew}`
        );
    }

    if (applied_updates && Object.keys(applied_updates).length) {
        lines.push(`DB updated → ${JSON.stringify(applied_updates)}`);
    } else if (status === 'no_change') {
        lines.push('DB unchanged (already matches store).');
    }

    if (message) lines.push(message);
    return lines;
};

const recordStoreSync = async ({
    row,
    sync_type = 'pull',
    status,
    message = null,
    snapshot = null,
    previous = null,
    applied_updates = null,
    user_updated = false,
    error_detail = null,
    performed_by = null,
    store_action_result = null,
    console_log = null
}) => {
    const summary = snapshotSummary(snapshot || store_action_result);
    let syncStatus = status;
    if (store_action_result?.action === 'manual_required') {
        syncStatus = 'manual_required';
    }

    const record = await UserSubscriptionStoreSync.create({
        user_subscription_id: row.id,
        user_id: row.user_id,
        platform: row.platform,
        sync_type,
        status: syncStatus,
        message: message || store_action_result?.message || null,
        ...summary,
        user_updated: Boolean(user_updated),
        previous_data: previous,
        store_snapshot: snapshot
            ? { ...snapshot, _adminConsoleLog: console_log || undefined }
            : store_action_result
              ? { ...store_action_result, _adminConsoleLog: console_log || undefined }
              : console_log
                ? { _adminConsoleLog: console_log }
                : null,
        applied_updates,
        error_detail,
        performed_by
    });

    const plain = record.get({ plain: true });
    return {
        ...plain,
        console:
            console_log ||
            buildConsoleLines({
                platform: row.platform,
                sync_type,
                status: syncStatus,
                message: plain.message,
                snapshot: snapshot || store_action_result,
                previous,
                applied_updates,
                error_detail
            })
    };
};

const listStoreSyncs = async (filters = {}) => {
    const where = {};
    if (filters.user_subscription_id) where.user_subscription_id = filters.user_subscription_id;
    if (filters.user_id) where.user_id = filters.user_id;

    const limit = Math.min(Math.max(Number(filters.limit) || 20, 1), 100);
    const page = Math.max(Number(filters.page) || 1, 1);
    const offset = (page - 1) * limit;

    const { count, rows } = await UserSubscriptionStoreSync.findAndCountAll({
        where,
        order: [['createdAt', 'DESC']],
        limit,
        offset
    });

    const data = rows.map((r) => {
        const plain = r.get({ plain: true });
        const storedLog = plain.store_snapshot?._adminConsoleLog;
        return {
            ...plain,
            console: storedLog?.length
                ? storedLog
                : buildConsoleLines({
                platform: plain.platform,
                sync_type: plain.sync_type,
                status: plain.status,
                message: plain.message,
                snapshot: plain.store_snapshot,
                previous: plain.previous_data,
                applied_updates: plain.applied_updates,
                error_detail: plain.error_detail
            })
        };
    });

    const totalPages = Math.max(Math.ceil(count / limit), 1);
    return {
        data,
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

const fetchStoreSnapshot = async (row, logger = null) => {
    const log = logger ? (msg) => logger.log(msg) : () => {};
    const platform = row.platform;
    const token = row.store_purchase_token ? String(row.store_purchase_token).trim() : '';

    if (platform === 'google_play') {
        log('Platform: Google Play');
        if (!isGooglePlayConfigured()) {
            throw new Error('Google Play is not configured.');
        }
        if (!token) {
            throw new Error('store_purchase_token is required to sync from Google Play.');
        }
        const playId = row.plan?.play_store_sub_id;
        if (!playId) {
            throw new Error('Plan has no play_store_sub_id.');
        }
        log(`Calling Play API (product: ${playId})…`);
        const result = await googlePlayStore.getSubscriptionPurchaseStatus(playId, token);
        log(`Play API OK (${result.apiVersion || 'v?'}) — status: ${result.status}`);
        return result;
    }

    if (platform === 'app_store') {
        log('Platform: App Store');
        if (!isAppleAppStoreConfigured()) {
            throw new Error('Apple App Store is not configured.');
        }
        if (!token) {
            throw new Error('store_purchase_token is required (Apple original transaction ID).');
        }
        log(`Calling App Store Server API (transaction: ${token.slice(0, 12)}…)…`);
        const result = await appleServer.getSubscriptionPurchaseStatus(token);
        log(`App Store API OK (${result.environment || '?'}) — status: ${result.status}`);
        return result;
    }

    throw new Error('Store sync is only available for google_play and app_store subscriptions.');
};

const buildUpdatesFromSnapshot = (row, snapshot) => {
    const updates = {};
    const previous = {
        status: row.status,
        expires_at: row.expires_at ? new Date(row.expires_at).toISOString() : null,
        auto_renew: row.auto_renew,
        cancelled_at: row.cancelled_at ? new Date(row.cancelled_at).toISOString() : null
    };

    if (snapshot.status && snapshot.status !== row.status) {
        updates.status = snapshot.status;
    }

    if (snapshot.expiresAt !== undefined) {
        const nextExpiry = snapshot.expiresAt ? new Date(snapshot.expiresAt) : null;
        const prevMs = row.expires_at ? new Date(row.expires_at).getTime() : null;
        const nextMs = nextExpiry ? nextExpiry.getTime() : null;
        if (prevMs !== nextMs) {
            updates.expires_at = nextExpiry;
        }
    }

    if (snapshot.autoRenew !== undefined && snapshot.autoRenew !== row.auto_renew) {
        updates.auto_renew = snapshot.autoRenew;
    }

    if (snapshot.cancelledAt) {
        const nextCancelled = new Date(snapshot.cancelledAt);
        const prevCancelledMs = row.cancelled_at ? new Date(row.cancelled_at).getTime() : null;
        if (prevCancelledMs !== nextCancelled.getTime()) {
            updates.cancelled_at = nextCancelled;
        }
    } else if (snapshot.status === 'active' && row.cancelled_at && row.status === 'cancelled') {
        updates.cancelled_at = null;
    }

    if (
        snapshot.startedAt &&
        row.started_at &&
        new Date(snapshot.startedAt).getTime() !== new Date(row.started_at).getTime()
    ) {
        updates.started_at = new Date(snapshot.startedAt);
    }

    return { updates, previous, snapshot };
};

module.exports = {
    fetchStoreSnapshot,
    buildUpdatesFromSnapshot,
    recordStoreSync,
    listStoreSyncs,
    buildConsoleLines,
    createSyncLogger
};
