const jwt = require('jsonwebtoken');
const { loadApplePrivateKey } = require('../../config/storeProvisioning');

const PRODUCTION_BASE = 'https://api.storekit.itunes.apple.com';
const SANDBOX_BASE = 'https://api.storekit-sandbox.itunes.apple.com';

const createServerApiJwt = () => {
    const issuerId = process.env.APPLE_ISSUER_ID;
    const keyId = process.env.APPLE_KEY_ID;
    const privateKey = loadApplePrivateKey();
    const bundleId =
        process.env.APPLE_BUNDLE_ID ||
        process.env.APPLE_SUBSCRIPTION_PRODUCT_ID_PREFIX ||
        'com.codesteem.repvio';

    if (!issuerId || !keyId || !privateKey) {
        throw new Error('Apple API credentials are incomplete.');
    }

    const now = Math.floor(Date.now() / 1000);
    return jwt.sign(
        {
            iss: issuerId,
            iat: now,
            exp: now + 1200,
            aud: 'appstoreconnect-v1',
            bid: bundleId
        },
        privateKey,
        {
            algorithm: 'ES256',
            header: { alg: 'ES256', kid: keyId, typ: 'JWT' }
        }
    );
};

const decodeJwsPayload = (jws) => {
    if (!jws || typeof jws !== 'string') return null;
    const parts = jws.split('.');
    if (parts.length < 2) return null;
    try {
        const json = Buffer.from(parts[1], 'base64url').toString('utf8');
        return JSON.parse(json);
    } catch {
        return null;
    }
};

const toDateFromApple = (value) => {
    if (value == null || value === '') return null;
    const n = Number(value);
    if (!Number.isFinite(n)) {
        const d = new Date(value);
        return Number.isNaN(d.getTime()) ? null : d;
    }
    const ms = n < 1e12 ? n * 1000 : n;
    return new Date(ms);
};

const mapAppleStatus = ({ transaction, renewal, expiresAt }) => {
    const now = Date.now();
    const expMs = expiresAt ? expiresAt.getTime() : null;
    const autoRenewOn = renewal?.autoRenewStatus === 1 || renewal?.autoRenewStatus === '1';
    const txStatus = Number(transaction?.status);
    const revoked = txStatus === 5;
    const expiredByDate = expMs != null && expMs < now;
    const expirationIntent = renewal?.expirationIntent;

    if (revoked) {
        return { status: 'cancelled', autoRenew: false };
    }

    if (expiredByDate || txStatus === 2) {
        return { status: 'expired', autoRenew: false };
    }

    if (txStatus === 4 || txStatus === 3) {
        return { status: 'active', autoRenew: autoRenewOn };
    }

    if (expirationIntent && !autoRenewOn) {
        return { status: expMs && expMs > now ? 'active' : 'cancelled', autoRenew: false };
    }

    if (txStatus === 1 || (expMs && expMs > now)) {
        return { status: 'active', autoRenew: autoRenewOn };
    }

    return { status: 'expired', autoRenew: false };
};

const parseAppleSubscriptionResponse = (json) => {
    const groups = json?.data || [];
    let latestTx = null;
    let latestRenewal = null;
    let latestExpires = null;

    for (const group of groups) {
        const items = group.lastTransactions || [];
        for (const item of items) {
            const tx = decodeJwsPayload(item.signedTransactionInfo);
            const renewal = decodeJwsPayload(item.signedRenewalInfo);
            const expiresAt = toDateFromApple(tx?.expiresDate);
            const expMs = expiresAt ? expiresAt.getTime() : 0;
            if (!latestTx || expMs >= (latestExpires?.getTime() || 0)) {
                latestTx = tx;
                latestRenewal = renewal;
                latestExpires = expiresAt;
            }
        }
    }

    if (!latestTx) {
        throw new Error('No transaction data returned from App Store.');
    }

    const { status, autoRenew } = mapAppleStatus({
        transaction: latestTx,
        renewal: latestRenewal,
        expiresAt: latestExpires
    });

    const startedAt = toDateFromApple(latestTx.purchaseDate || latestTx.originalPurchaseDate);
    const cancelledAt =
        status === 'cancelled' && latestRenewal?.expirationIntent
            ? toDateFromApple(latestRenewal.recentSubscriptionStartDate) || new Date()
            : null;

    return {
        platform: 'app_store',
        productId: latestTx.productId || null,
        originalTransactionId: latestTx.originalTransactionId || latestTx.transactionId || null,
        expiresAt: latestExpires,
        startedAt,
        autoRenew,
        status,
        cancelledAt,
        raw: {
            transaction: latestTx,
            renewal: latestRenewal
        }
    };
};

const fetchAppleStatuses = async (originalTransactionId, sandbox) => {
    const base = sandbox ? SANDBOX_BASE : PRODUCTION_BASE;
    const token = createServerApiJwt();
    const res = await fetch(
        `${base}/inApps/v1/subscriptions/${encodeURIComponent(originalTransactionId)}`,
        { headers: { Authorization: `Bearer ${token}` } }
    );

    const text = await res.text();
    let json = {};
    if (text) {
        try {
            json = JSON.parse(text);
        } catch {
            json = { raw: text };
        }
    }

    return { ok: res.ok, status: res.status, json };
};

/**
 * Latest subscription state from App Store Server API (production, then sandbox).
 * store_purchase_token should be the original transaction ID.
 */
const getSubscriptionPurchaseStatus = async (originalTransactionId) => {
    const id = String(originalTransactionId).trim();
    if (!id) {
        throw new Error('App Store original transaction ID is required.');
    }

    const preferSandbox = process.env.APPLE_IAP_SANDBOX === 'true';
    const order = preferSandbox ? [true, false] : [false, true];

    let lastError = null;
    for (const sandbox of order) {
        try {
            const { ok, status, json } = await fetchAppleStatuses(id, sandbox);
            if (ok) {
                const parsed = parseAppleSubscriptionResponse(json);
                parsed.environment = sandbox ? 'sandbox' : 'production';
                return parsed;
            }
            if (status === 404) {
                lastError = new Error(
                    sandbox
                        ? 'Subscription not found on App Store (sandbox).'
                        : 'Subscription not found on App Store (production).'
                );
                continue;
            }
            const detail =
                json.errors?.map((e) => e.detail || e.title).join('; ') ||
                json.errorMessage ||
                `App Store API error (HTTP ${status})`;
            throw new Error(detail);
        } catch (err) {
            lastError = err;
            if (err.message && !err.message.includes('not found')) {
                throw err;
            }
        }
    }

    throw lastError || new Error('Could not load subscription from App Store.');
};

/**
 * Apple does not expose developer-initiated cancel/refund APIs for standard IAP.
 * We verify the transaction exists and return guidance for App Store Connect.
 */
const cancelSubscriptionPurchase = async (originalTransactionId) => {
    const status = await getSubscriptionPurchaseStatus(originalTransactionId);
    return {
        action: 'manual_required',
        platform: 'app_store',
        environment: status.environment,
        productId: status.productId,
        message:
            'Apple does not allow cancelling a subscription via API. Stop renewals in App Store Connect (transaction/subscription) or the user cancels in iOS Settings → Subscriptions.',
        appStoreConnect: 'https://appstoreconnect.apple.com/'
    };
};

const refundSubscriptionPurchase = async (originalTransactionId) => {
    const status = await getSubscriptionPurchaseStatus(originalTransactionId);
    return {
        action: 'manual_required',
        platform: 'app_store',
        environment: status.environment,
        productId: status.productId,
        message:
            'Apple refunds must be issued in App Store Connect (Sales and Trends / user transaction) or when the customer requests a refund. There is no server API to refund on behalf of the user.',
        appStoreConnect: 'https://appstoreconnect.apple.com/'
    };
};

module.exports = {
    getSubscriptionPurchaseStatus,
    cancelSubscriptionPurchase,
    refundSubscriptionPurchase,
    decodeJwsPayload
};
