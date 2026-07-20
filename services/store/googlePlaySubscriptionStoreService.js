const { google } = require('googleapis');
const { loadGoogleCredentials } = require('../../config/storeProvisioning');
const { toGoogleMoney } = require('../../utils/googleMoney');

const SCOPE = 'https://www.googleapis.com/auth/androidpublisher';

let cachedAuth = null;

const getGoogleAuth = async () => {
    if (cachedAuth) return cachedAuth;

    const credentials = loadGoogleCredentials();
    if (!credentials) {
        throw new Error('Google Play service account is not configured.');
    }

    cachedAuth = new google.auth.GoogleAuth({
        credentials,
        scopes: [SCOPE]
    });
    return cachedAuth;
};

const getAccessToken = async () => {
    const auth = await getGoogleAuth();
    const client = await auth.getClient();
    const tokenResponse = await client.getAccessToken();
    const token = typeof tokenResponse === 'string' ? tokenResponse : tokenResponse?.token;
    if (!token) {
        throw new Error('Failed to obtain Google Play API access token.');
    }
    return token;
};

const priceToRegionalConfig = (price, currency, regionCode) => ({
    regionCode,
    newSubscriberAvailability: true,
    price: toGoogleMoney(price, currency)
});

/** Play requires a listing in the app's default store language (e.g. en-GB). */
const buildSubscriptionListings = (title, description) => {
    const raw =
        process.env.GOOGLE_PLAY_LISTING_LANGUAGES ||
        process.env.GOOGLE_PLAY_DEFAULT_LANGUAGE ||
        'en-GB';
    const languages = [...new Set(raw.split(',').map((s) => s.trim()).filter(Boolean))];

    return languages.map((languageCode) => ({
        languageCode,
        title: title.slice(0, 55),
        description: (description || title).slice(0, 80)
    }));
};

const playApiRequest = async (method, pathSuffix, body) => {
    const packageName = process.env.GOOGLE_PLAY_PACKAGE_NAME;
    if (!packageName) {
        throw new Error('GOOGLE_PLAY_PACKAGE_NAME is required.');
    }

    const token = await getAccessToken();
    const url = `https://androidpublisher.googleapis.com/androidpublisher/v3/applications/${encodeURIComponent(packageName)}${pathSuffix}`;

    const headers = { Authorization: `Bearer ${token}` };
    const init = { method, headers };
    if (body !== undefined) {
        headers['Content-Type'] = 'application/json';
        init.body = JSON.stringify(body);
    }

    const res = await fetch(url, init);

    const text = await res.text();
    let data = null;
    if (text) {
        try {
            data = JSON.parse(text);
        } catch {
            data = { raw: text };
        }
    }

    return { ok: res.ok, status: res.status, data };
};

const apiErrorMessage = (data, status, fallback) =>
    data?.error?.message ||
    data?.message ||
    (typeof data?.error === 'string' ? data.error : null) ||
    `${fallback} (HTTP ${status}).`;

const getSubscription = async (productId) => {
    const id = String(productId).trim();
    if (!id) {
        throw new Error('Play Store product ID is required.');
    }

    const { ok, status, data } = await playApiRequest(
        'GET',
        `/subscriptions/${encodeURIComponent(id)}`
    );

    if (status === 404) {
        return { exists: false, productId: id };
    }

    if (!ok) {
        const detail =
            data?.error?.message ||
            data?.message ||
            (typeof data?.error === 'string' ? data.error : null) ||
            'Failed to fetch subscription from Google Play.';
        throw new Error(detail);
    }

    const basePlans = (data.basePlans || []).map((bp) => ({
        basePlanId: bp.basePlanId,
        state: bp.state || 'UNKNOWN'
    }));

    return {
        exists: true,
        productId: data.productId || id,
        packageName: data.packageName,
        listings: (data.listings || []).map((l) => ({
            languageCode: l.languageCode,
            title: l.title
        })),
        basePlans,
        archived: Boolean(data.archived)
    };
};

const activateBasePlan = async (productId, basePlanId) => {
    const id = String(productId).trim();
    const planId = String(basePlanId).trim();
    if (!id || !planId) {
        throw new Error('productId and basePlanId are required to activate.');
    }

    const { ok, status, data } = await playApiRequest(
        'POST',
        `/subscriptions/${encodeURIComponent(id)}/basePlans/${encodeURIComponent(planId)}:activate`,
        {}
    );

    if (!ok) {
        const detail =
            data?.error?.message ||
            data?.message ||
            (typeof data?.error === 'string' ? data.error : null) ||
            `Activate failed (HTTP ${status}).`;
        throw new Error(detail);
    }

    const activated = (data?.basePlans || []).find((bp) => bp.basePlanId === planId);
    return {
        productId: data?.productId || id,
        basePlanId: planId,
        state: activated?.state || 'ACTIVE'
    };
};

const activateAllDraftBasePlans = async (productId) => {
    const sub = await getSubscription(productId);
    if (!sub.exists) {
        throw new Error('Subscription not found on Google Play.');
    }

    const defaultBasePlanId = process.env.GOOGLE_PLAY_BASE_PLAN_ID || 'default';
    const draftPlans = (sub.basePlans || []).filter((bp) => bp.state === 'DRAFT');
    const toActivate =
        draftPlans.length > 0
            ? draftPlans
            : sub.basePlans?.length
              ? [{ basePlanId: sub.basePlans[0].basePlanId, state: sub.basePlans[0].state }]
              : [{ basePlanId: defaultBasePlanId, state: 'DRAFT' }];

    const activated = [];
    const errors = [];

    for (const bp of toActivate) {
        if (bp.state === 'ACTIVE') {
            activated.push({ basePlanId: bp.basePlanId, state: 'ACTIVE', skipped: true });
            continue;
        }
        try {
            const result = await activateBasePlan(productId, bp.basePlanId);
            activated.push(result);
        } catch (err) {
            errors.push({ basePlanId: bp.basePlanId, message: err.message });
        }
    }

    if (!activated.length && errors.length) {
        throw new Error(errors.map((e) => `${e.basePlanId}: ${e.message}`).join(' | '));
    }

    const refreshed = await getSubscription(productId);
    return {
        productId,
        activated,
        errors,
        basePlans: refreshed.basePlans || []
    };
};

const createSubscription = async ({
    productId,
    title,
    description,
    price,
    currency,
    billingPeriod = 'P1M'
}) => {
    const packageName = process.env.GOOGLE_PLAY_PACKAGE_NAME;
    if (!packageName) {
        throw new Error('GOOGLE_PLAY_PACKAGE_NAME is required.');
    }

    const regionCode = process.env.GOOGLE_PLAY_DEFAULT_REGION || 'US';
    const regionsVersion = process.env.GOOGLE_PLAY_REGIONS_VERSION || '2022/02';
    const basePlanId = process.env.GOOGLE_PLAY_BASE_PLAN_ID || 'default';

    const money = toGoogleMoney(price, currency);

    const subscriptionBody = {
        packageName,
        productId,
        listings: buildSubscriptionListings(title, description),
        basePlans: [
            {
                basePlanId,
                autoRenewingBasePlanType: {
                    billingPeriodDuration: billingPeriod
                },
                regionalConfigs: [priceToRegionalConfig(price, currency, regionCode)],
                otherRegionsConfig: {
                    usdPrice: currency === 'USD' ? money : toGoogleMoney(price, 'USD'),
                    eurPrice: currency === 'EUR' ? money : toGoogleMoney(price, 'EUR'),
                    newSubscriberAvailability: true
                }
            }
        ]
    };

    const token = await getAccessToken();

    // googleapis client mishandles regionsVersion object; use REST query param directly.
    const url = new URL(
        `https://androidpublisher.googleapis.com/androidpublisher/v3/applications/${encodeURIComponent(packageName)}/subscriptions`
    );
    url.searchParams.set('productId', productId);
    url.searchParams.set('regionsVersion.version', regionsVersion);

    const res = await fetch(url.toString(), {
        method: 'POST',
        headers: {
            Authorization: `Bearer ${token}`,
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(subscriptionBody)
    });

    const text = await res.text();
    let data = {};
    if (text) {
        try {
            data = JSON.parse(text);
        } catch {
            data = { raw: text };
        }
    }

    if (!res.ok) {
        const detail =
            data.error?.message ||
            data.message ||
            (typeof data.error === 'string' ? data.error : null) ||
            res.statusText;
        throw new Error(detail);
    }

    const created = {
        productId: data.productId || productId,
        packageName: data.packageName || packageName,
        state: data.basePlans?.[0]?.state || 'DRAFT'
    };

    const autoActivate = process.env.GOOGLE_PLAY_AUTO_ACTIVATE !== 'false';
    if (autoActivate) {
        try {
            const activation = await activateAllDraftBasePlans(created.productId);
            created.activation = activation;
            created.state = activation.basePlans?.[0]?.state || created.state;
        } catch (err) {
            created.activationError = err.message;
        }
    }

    return created;
};

const verifySubscription = async (productId) => {
    const result = await getSubscription(productId);
    return {
        ...result,
        verifiedAt: new Date().toISOString(),
        packageName: result.packageName || process.env.GOOGLE_PLAY_PACKAGE_NAME
    };
};

const deleteBasePlan = async (productId, basePlanId) => {
    const id = String(productId).trim();
    const planId = String(basePlanId).trim();
    const { ok, status, data } = await playApiRequest(
        'DELETE',
        `/subscriptions/${encodeURIComponent(id)}/basePlans/${encodeURIComponent(planId)}`
    );
    if (!ok) {
        throw new Error(apiErrorMessage(data, status, 'Delete base plan failed'));
    }
    return { productId: id, basePlanId: planId, action: 'deleted' };
};

const deactivateBasePlan = async (productId, basePlanId) => {
    const id = String(productId).trim();
    const planId = String(basePlanId).trim();
    const { ok, status, data } = await playApiRequest(
        'POST',
        `/subscriptions/${encodeURIComponent(id)}/basePlans/${encodeURIComponent(planId)}:deactivate`,
        {}
    );
    if (!ok) {
        throw new Error(apiErrorMessage(data, status, 'Deactivate base plan failed'));
    }
    return { productId: id, basePlanId: planId, action: 'deactivated' };
};

const deleteSubscriptionProduct = async (productId) => {
    const id = String(productId).trim();
    const { ok, status, data } = await playApiRequest(
        'DELETE',
        `/subscriptions/${encodeURIComponent(id)}`
    );
    if (!ok) {
        throw new Error(apiErrorMessage(data, status, 'Delete subscription failed'));
    }
    return { productId: id, action: 'subscription_deleted' };
};

const archiveSubscriptionProduct = async (productId) => {
    const id = String(productId).trim();
    const { ok, status, data } = await playApiRequest(
        'POST',
        `/subscriptions/${encodeURIComponent(id)}:archive`,
        {}
    );
    if (!ok) {
        throw new Error(apiErrorMessage(data, status, 'Archive subscription failed'));
    }
    return { productId: id, action: 'archived', archived: Boolean(data?.archived) };
};

/**
 * Best-effort Play removal: draft base plans deleted, live ones deactivated,
 * archive + full delete when Google allows.
 */
const removeSubscriptionFromPlay = async (productId) => {
    const id = String(productId).trim();
    const sub = await getSubscription(id);

    if (!sub.exists) {
        return {
            productId: id,
            skipped: true,
            reason: 'not_found_on_play'
        };
    }

    const result = {
        productId: id,
        deletedBasePlans: [],
        deactivatedBasePlans: [],
        subscriptionDeleted: false,
        subscriptionArchived: false,
        warnings: []
    };

    const defaultBasePlanId = process.env.GOOGLE_PLAY_BASE_PLAN_ID || 'default';
    const basePlans =
        sub.basePlans?.length > 0
            ? sub.basePlans
            : [{ basePlanId: defaultBasePlanId, state: 'DRAFT' }];

    for (const bp of basePlans) {
        const state = (bp.state || '').toUpperCase();
        try {
            if (state === 'DRAFT') {
                await deleteBasePlan(id, bp.basePlanId);
                result.deletedBasePlans.push(bp.basePlanId);
                continue;
            }

            if (state === 'INACTIVE') {
                result.deactivatedBasePlans.push(bp.basePlanId);
                continue;
            }

            try {
                await deactivateBasePlan(id, bp.basePlanId);
                result.deactivatedBasePlans.push(bp.basePlanId);
            } catch (deactErr) {
                try {
                    await deleteBasePlan(id, bp.basePlanId);
                    result.deletedBasePlans.push(bp.basePlanId);
                } catch {
                    result.warnings.push(`${bp.basePlanId}: ${deactErr.message}`);
                }
            }
        } catch (err) {
            result.warnings.push(`${bp.basePlanId}: ${err.message}`);
        }
    }

    if (!sub.archived) {
        try {
            await archiveSubscriptionProduct(id);
            result.subscriptionArchived = true;
        } catch (err) {
            result.warnings.push(`Archive: ${err.message}`);
        }
    } else {
        result.subscriptionArchived = true;
    }

    try {
        await deleteSubscriptionProduct(id);
        result.subscriptionDeleted = true;
    } catch (err) {
        result.warnings.push(
            `Full subscription not removed on Play: ${err.message} (normal if it was ever published/activated).`
        );
    }

    result.subscriptionDeactivated =
        result.deactivatedBasePlans.length > 0 ||
        result.subscriptionArchived ||
        result.subscriptionDeleted;

    return result;
};

/**
 * Revoke a user's Play subscription (immediate access end, no refund).
 * @see https://developers.google.com/android-publisher/api-ref/rest/v3/purchases.subscriptions/revoke
 */
const revokeSubscriptionPurchase = async (subscriptionId, purchaseToken) => {
    const subId = String(subscriptionId).trim();
    const token = String(purchaseToken).trim();
    if (!subId || !token) {
        throw new Error('Play subscription ID and purchase token are required.');
    }

    const { ok, status, data } = await playApiRequest(
        'POST',
        `/purchases/subscriptions/${encodeURIComponent(subId)}/tokens/${encodeURIComponent(token)}:revoke`
    );

    if (!ok) {
        throw new Error(apiErrorMessage(data, status, 'Failed to revoke subscription on Google Play.'));
    }

    return { subscriptionId: subId, action: 'revoked' };
};

/**
 * Refund and revoke a Play subscription purchase.
 * @see https://developers.google.com/android-publisher/api-ref/rest/v3/purchases.subscriptions/refund
 */
const mapGoogleV2Purchase = (data) => {
    const state = String(data.subscriptionState || '').toUpperCase();
    const line = (data.lineItems || [])[0] || {};
    const expiry = line.expiryTime ? new Date(line.expiryTime) : null;
    const now = Date.now();
    const expMs = expiry && !Number.isNaN(expiry.getTime()) ? expiry.getTime() : null;

    let autoRenew = false;
    if (line.autoRenewingPlan && typeof line.autoRenewingPlan.autoRenewEnabled === 'boolean') {
        autoRenew = line.autoRenewingPlan.autoRenewEnabled;
    }

    let status = 'active';
    if (state === 'SUBSCRIPTION_STATE_EXPIRED') {
        status = 'expired';
        autoRenew = false;
    } else if (
        state === 'SUBSCRIPTION_STATE_PAUSED' ||
        state === 'SUBSCRIPTION_STATE_ON_HOLD'
    ) {
        status = 'paused';
        autoRenew = false;
    } else if (state === 'SUBSCRIPTION_STATE_PENDING') {
        status = 'trialing';
    } else if (state === 'SUBSCRIPTION_STATE_CANCELED') {
        status = expMs && expMs > now ? 'active' : 'cancelled';
        autoRenew = false;
    } else if (expMs && expMs < now) {
        status = 'expired';
        autoRenew = false;
    }

    let cancelledAt = null;
    if (data.canceledStateContext) {
        cancelledAt = new Date();
    }

    const startedAt = line.latestSuccessfulOrderId
        ? null
        : data.startTime
          ? new Date(data.startTime)
          : null;

    return {
        platform: 'google_play',
        productId: line.productId || data.productId || null,
        expiresAt: expiry,
        startedAt,
        autoRenew: status === 'cancelled' || status === 'expired' ? false : Boolean(autoRenew),
        status,
        cancelledAt,
        subscriptionState: state,
        raw: data
    };
};

const mapGoogleV1Purchase = (data) => {
    const expiryMs = data.expiryTimeMillis != null ? Number(data.expiryTimeMillis) : null;
    const expiry = expiryMs ? new Date(expiryMs) : null;
    const now = Date.now();
    const autoRenew = Boolean(data.autoRenewing);
    const paymentState = data.paymentState != null ? Number(data.paymentState) : null;
    const cancelReason = data.cancelReason != null ? Number(data.cancelReason) : null;

    let status = 'active';
    if (expiryMs && expiryMs < now) {
        status = 'expired';
    } else if (cancelReason != null) {
        status = expiryMs && expiryMs > now ? 'active' : 'cancelled';
    } else if (paymentState === 0) {
        status = 'trialing';
    }

    const cancelledAt =
        data.userCancellationTimeMillis != null
            ? new Date(Number(data.userCancellationTimeMillis))
            : cancelReason != null
              ? new Date()
              : null;

    return {
        platform: 'google_play',
        productId: data.productId || null,
        expiresAt: expiry,
        startedAt:
            data.startTimeMillis != null ? new Date(Number(data.startTimeMillis)) : null,
        autoRenew: status === 'cancelled' || status === 'expired' ? false : autoRenew,
        status,
        cancelledAt,
        paymentState,
        raw: data
    };
};

/**
 * Latest purchase state for a subscription token (v2, then v1 fallback).
 */
const getSubscriptionPurchaseStatus = async (productId, purchaseToken) => {
    const token = String(purchaseToken).trim();
    if (!token) {
        throw new Error('Google Play purchase token is required.');
    }

    const v2 = await playApiRequest(
        'GET',
        `/purchases/subscriptionsv2/tokens/${encodeURIComponent(token)}`
    );

    if (v2.ok && v2.data) {
        const mapped = mapGoogleV2Purchase(v2.data);
        mapped.apiVersion = 'v2';
        return mapped;
    }

    const subId = productId != null ? String(productId).trim() : '';
    if (!subId) {
        throw new Error(
            apiErrorMessage(v2.data, v2.status, 'Google Play purchase lookup failed (v2)')
        );
    }

    const v1 = await playApiRequest(
        'GET',
        `/purchases/subscriptions/${encodeURIComponent(subId)}/tokens/${encodeURIComponent(token)}`
    );

    if (!v1.ok) {
        throw new Error(apiErrorMessage(v1.data, v1.status, 'Google Play purchase lookup failed'));
    }

    const mapped = mapGoogleV1Purchase(v1.data);
    mapped.apiVersion = 'v1';
    mapped.productId = mapped.productId || subId;
    return mapped;
};

/**
 * Stop future renewals; access continues until expiry (Play policy).
 * @see purchases.subscriptionsv2.cancel / purchases.subscriptions.cancel
 */
const cancelSubscriptionPurchase = async (
    productId,
    purchaseToken,
    cancellationType = 'USER_REQUESTED_STOP_RENEWALS'
) => {
    const token = String(purchaseToken).trim();
    if (!token) {
        throw new Error('Google Play purchase token is required.');
    }

    const body = { cancellationContext: { cancellationType } };
    const v2 = await playApiRequest(
        'POST',
        `/purchases/subscriptionsv2/tokens/${encodeURIComponent(token)}:cancel`,
        body
    );

    if (v2.ok) {
        return {
            subscriptionId: productId || null,
            action: 'cancelled',
            apiVersion: 'v2',
            cancellationType
        };
    }

    const subId = productId != null ? String(productId).trim() : '';
    if (!subId) {
        throw new Error(apiErrorMessage(v2.data, v2.status, 'Google Play cancel failed (v2)'));
    }

    const v1Body = { cancellationType };
    const v1 = await playApiRequest(
        'POST',
        `/purchases/subscriptions/${encodeURIComponent(subId)}/tokens/${encodeURIComponent(token)}:cancel`,
        v1Body
    );

    if (!v1.ok) {
        throw new Error(apiErrorMessage(v1.data, v1.status, 'Google Play cancel failed'));
    }

    return {
        subscriptionId: subId,
        action: 'cancelled',
        apiVersion: 'v1',
        cancellationType
    };
};

const refundSubscriptionPurchase = async (subscriptionId, purchaseToken) => {
    const subId = String(subscriptionId).trim();
    const token = String(purchaseToken).trim();
    if (!subId || !token) {
        throw new Error('Play subscription ID and purchase token are required.');
    }

    const { ok, status, data } = await playApiRequest(
        'POST',
        `/purchases/subscriptions/${encodeURIComponent(subId)}/tokens/${encodeURIComponent(token)}:refund`
    );

    if (!ok) {
        throw new Error(apiErrorMessage(data, status, 'Failed to refund subscription on Google Play.'));
    }

    return { subscriptionId: subId, action: 'refunded' };
};

module.exports = {
    createSubscription,
    getSubscription,
    verifySubscription,
    activateBasePlan,
    activateAllDraftBasePlans,
    deleteBasePlan,
    deactivateBasePlan,
    deleteSubscriptionProduct,
    archiveSubscriptionProduct,
    removeSubscriptionFromPlay,
    revokeSubscriptionPurchase,
    cancelSubscriptionPurchase,
    refundSubscriptionPurchase,
    getSubscriptionPurchaseStatus
};
