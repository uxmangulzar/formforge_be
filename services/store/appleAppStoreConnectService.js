const fs = require('fs');
const path = require('path');
const jwt = require('jsonwebtoken');
const { loadApplePrivateKey, resolveProjectPath } = require('../../config/storeProvisioning');

const API_BASE = 'https://api.appstoreconnect.apple.com/v1';

let cachedGroupId = null;

const createAppStoreJwt = () => {
    const issuerId = process.env.APPLE_ISSUER_ID;
    const keyId = process.env.APPLE_KEY_ID;
    const privateKey = loadApplePrivateKey();

    if (!issuerId || !keyId || !privateKey) {
        throw new Error('Apple App Store Connect API credentials are incomplete.');
    }

    const now = Math.floor(Date.now() / 1000);
    return jwt.sign(
        {
            iss: issuerId,
            iat: now,
            exp: now + 1200,
            aud: 'appstoreconnect-v1'
        },
        privateKey,
        {
            algorithm: 'ES256',
            header: { alg: 'ES256', kid: keyId, typ: 'JWT' }
        }
    );
};

const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

const apiRequest = async (method, path, body, options = {}) => {
    const maxAttempts = options.retries ?? 3;
    let lastError = null;

    for (let attempt = 1; attempt <= maxAttempts; attempt += 1) {
        const token = createAppStoreJwt();
        const headers = { Authorization: `Bearer ${token}` };
        if (body !== undefined) {
            headers['Content-Type'] = 'application/json';
        }

        const res = await fetch(`${API_BASE}${path}`, {
            method,
            headers,
            body: body !== undefined ? JSON.stringify(body) : undefined
        });

        const text = await res.text();
        let json = {};
        if (text) {
            try {
                json = JSON.parse(text);
            } catch {
                json = { raw: text };
            }
        }

        if (res.ok) {
            return json;
        }

        if (options.allowNotFound && res.status === 404) {
            return null;
        }

        const detail =
            json.errors?.map((e) => `${e.title || 'Error'}: ${e.detail || e.code}`).join('; ') ||
            json.message ||
            res.statusText;
        lastError = new Error(`[${res.status}] ${detail}`);

        const retryable = res.status === 401 || res.status === 429;
        if (!retryable || attempt === maxAttempts) {
            throw lastError;
        }

        await sleep(attempt * 1000);
    }

    throw lastError;
};

const resolveSubscriptionGroupId = async () => {
    if (process.env.APPLE_SUBSCRIPTION_GROUP_ID) {
        return process.env.APPLE_SUBSCRIPTION_GROUP_ID;
    }
    if (cachedGroupId) return cachedGroupId;

    if (process.env.APPLE_AUTO_CREATE_SUBSCRIPTION_GROUP !== 'true') {
        throw new Error(
            'APPLE_SUBSCRIPTION_GROUP_ID is required (or set APPLE_AUTO_CREATE_SUBSCRIPTION_GROUP=true).'
        );
    }

    const appId = process.env.APPLE_APP_ID;
    const referenceName =
        process.env.APPLE_SUBSCRIPTION_GROUP_REFERENCE_NAME || 'FormForge Subscriptions';

    const created = await apiRequest('POST', '/subscriptionGroups', {
        data: {
            type: 'subscriptionGroups',
            attributes: { referenceName },
            relationships: {
                app: {
                    data: { type: 'apps', id: appId }
                }
            }
        }
    });

    cachedGroupId = created.data.id;
    return cachedGroupId;
};

const mapBillingPeriod = (billingPeriod) => {
    const map = {
        P1W: 'ONE_WEEK',
        P1M: 'ONE_MONTH',
        P2M: 'TWO_MONTHS',
        P3M: 'THREE_MONTHS',
        P6M: 'SIX_MONTHS',
        P1Y: 'ONE_YEAR'
    };
    return map[billingPeriod] || 'ONE_MONTH';
};

const isAutoCompleteMetadataEnabled = () => process.env.APPLE_AUTO_COMPLETE_METADATA === 'true';

const getDefaultLocale = () => process.env.APPLE_DEFAULT_LOCALE || 'en-US';

const normalizeTerritory = (territory) => {
    const code = String(territory || process.env.APPLE_DEFAULT_TERRITORY || 'USA')
        .trim()
        .toUpperCase();
    if (code === 'US') return 'USA';
    return code;
};

const listSubscriptionLocalizations = async (subscriptionId) => {
    const json = await apiRequest(
        'GET',
        `/subscriptions/${encodeURIComponent(subscriptionId)}/subscriptionLocalizations?limit=200`
    );
    return json.data || [];
};

const createSubscriptionLocalization = async (subscriptionId, { locale, name, description }) => {
    return apiRequest('POST', '/subscriptionLocalizations', {
        data: {
            type: 'subscriptionLocalizations',
            attributes: {
                locale,
                name: String(name).slice(0, 30),
                description: String(description || name).slice(0, 45)
            },
            relationships: {
                subscription: {
                    data: { type: 'subscriptions', id: String(subscriptionId) }
                }
            }
        }
    });
};

const ensureSubscriptionLocalization = async (subscriptionId, { name, description, locale }) => {
    const resolvedLocale = locale || getDefaultLocale();
    const existing = await listSubscriptionLocalizations(subscriptionId);
    const hasLocale = existing.some((item) => item.attributes?.locale === resolvedLocale);
    if (hasLocale) {
        return { skipped: true, locale: resolvedLocale, reason: 'already_exists' };
    }

    const created = await createSubscriptionLocalization(subscriptionId, {
        locale: resolvedLocale,
        name,
        description
    });
    return {
        skipped: false,
        locale: resolvedLocale,
        localizationId: created.data?.id
    };
};

const listSubscriptionPrices = async (subscriptionId) => {
    const json = await apiRequest(
        'GET',
        `/subscriptions/${encodeURIComponent(subscriptionId)}/prices?limit=200`
    );
    return json.data || [];
};

const listSubscriptionPricePoints = async (subscriptionId, territory) => {
    const all = [];
    let path = `/subscriptions/${encodeURIComponent(subscriptionId)}/pricePoints?filter[territory]=${encodeURIComponent(territory)}&limit=200`;

    while (path) {
        const json = await apiRequest('GET', path);
        all.push(...(json.data || []));
        const next = json.links?.next;
        if (!next) break;
        path = String(next).startsWith('http') ? String(next).replace(API_BASE, '') : next;
    }

    return all;
};

const pickPricePoint = (pricePoints, targetPrice) => {
    const target = Number(targetPrice);
    if (!Number.isFinite(target) || target <= 0) {
        return null;
    }

    let best = null;
    let bestDiff = Infinity;
    for (const point of pricePoints) {
        const customerPrice = Number(point.attributes?.customerPrice);
        if (!Number.isFinite(customerPrice)) continue;
        const diff = Math.abs(customerPrice - target);
        if (diff < bestDiff) {
            bestDiff = diff;
            best = point;
        }
    }
    return best;
};

const createSubscriptionPrice = async (subscriptionId, pricePointId) => {
    return apiRequest('POST', '/subscriptionPrices', {
        data: {
            type: 'subscriptionPrices',
            attributes: {
                startDate: null,
                preserveCurrentPrice: false
            },
            relationships: {
                subscription: {
                    data: { type: 'subscriptions', id: String(subscriptionId) }
                },
                subscriptionPricePoint: {
                    data: { type: 'subscriptionPricePoints', id: String(pricePointId) }
                }
            }
        }
    });
};

const ensureSubscriptionPrice = async (subscriptionId, { price, territory }) => {
    const existingPrices = await listSubscriptionPrices(subscriptionId);
    if (existingPrices.length > 0) {
        return { skipped: true, territory, reason: 'already_exists' };
    }

    const numericPrice = Number(price);
    if (!Number.isFinite(numericPrice) || numericPrice <= 0) {
        throw new Error('Plan price is required to set App Store subscription pricing.');
    }

    const pricePoints = await listSubscriptionPricePoints(subscriptionId, territory);
    if (!pricePoints.length) {
        throw new Error(`No App Store price points found for territory ${territory}.`);
    }

    const pricePoint = pickPricePoint(pricePoints, numericPrice);
    if (!pricePoint) {
        throw new Error(`Could not select a price point for territory ${territory}.`);
    }

    const created = await createSubscriptionPrice(subscriptionId, pricePoint.id);
    return {
        skipped: false,
        territory,
        pricePointId: pricePoint.id,
        customerPrice: pricePoint.attributes?.customerPrice || null,
        subscriptionPriceId: created.data?.id
    };
};

const getSubscriptionAvailability = async (subscriptionId) => {
    const json = await apiRequest(
        'GET',
        `/subscriptionAvailabilities/${encodeURIComponent(subscriptionId)}`,
        undefined,
        { allowNotFound: true }
    );
    return json?.data || null;
};

const listSubscriptionGroupLocalizations = async (groupId) => {
    const json = await apiRequest(
        'GET',
        `/subscriptionGroups/${encodeURIComponent(groupId)}/subscriptionGroupLocalizations?limit=50`
    );
    return json.data || [];
};

const ensureSubscriptionGroupLocalization = async (groupId, { name, locale }) => {
    const resolvedLocale = locale || getDefaultLocale();
    const existing = await listSubscriptionGroupLocalizations(groupId);
    if (existing.some((item) => item.attributes?.locale === resolvedLocale)) {
        return { skipped: true, locale: resolvedLocale, reason: 'already_exists' };
    }

    const displayName =
        name || process.env.APPLE_SUBSCRIPTION_GROUP_DISPLAY_NAME || 'Premium Subscriptions';

    const created = await apiRequest('POST', '/subscriptionGroupLocalizations', {
        data: {
            type: 'subscriptionGroupLocalizations',
            attributes: {
                locale: resolvedLocale,
                name: String(displayName).slice(0, 75)
            },
            relationships: {
                subscriptionGroup: {
                    data: { type: 'subscriptionGroups', id: String(groupId) }
                }
            }
        }
    });

    return {
        skipped: false,
        locale: resolvedLocale,
        localizationId: created.data?.id
    };
};

const getSubscriptionReviewScreenshot = async (subscriptionId) => {
    const json = await apiRequest(
        'GET',
        `/subscriptions/${encodeURIComponent(subscriptionId)}/appStoreReviewScreenshot`,
        undefined,
        { allowNotFound: true }
    );
    return json?.data || null;
};

const uploadSubscriptionReviewScreenshot = async (subscriptionId, filePath) => {
    const resolved = resolveProjectPath(filePath);
    if (!resolved || !fs.existsSync(resolved)) {
        throw new Error(`Review screenshot not found: ${filePath}`);
    }

    const buffer = fs.readFileSync(resolved);
    const fileName = path.basename(resolved);
    const ext = path.extname(fileName).toLowerCase();
    const contentType =
        ext === '.jpg' || ext === '.jpeg' ? 'image/jpeg' : 'image/png';

    const created = await apiRequest('POST', '/subscriptionAppStoreReviewScreenshots', {
        data: {
            type: 'subscriptionAppStoreReviewScreenshots',
            attributes: {
                fileName,
                fileSize: buffer.length
            },
            relationships: {
                subscription: {
                    data: { type: 'subscriptions', id: String(subscriptionId) }
                }
            }
        }
    });

    const screenshotId = created.data?.id;
    const uploadOp = created.data?.attributes?.uploadOperations?.[0];
    if (!screenshotId || !uploadOp?.url) {
        throw new Error('Apple did not return a review screenshot upload URL.');
    }

    const putRes = await fetch(uploadOp.url, {
        method: uploadOp.method || 'PUT',
        headers: { 'Content-Type': contentType },
        body: buffer
    });
    if (!putRes.ok) {
        throw new Error(`Review screenshot upload failed (${putRes.status}).`);
    }

    await apiRequest('PATCH', `/subscriptionAppStoreReviewScreenshots/${screenshotId}`, {
        data: {
            type: 'subscriptionAppStoreReviewScreenshots',
            id: screenshotId,
            attributes: { uploaded: true }
        }
    });

    for (let attempt = 0; attempt < 6; attempt += 1) {
        await sleep(1500);
        const detail = await apiRequest(
            'GET',
            `/subscriptionAppStoreReviewScreenshots/${screenshotId}`
        );
        const delivery = detail.data?.attributes?.assetDeliveryState;
        if (delivery?.state === 'COMPLETE') {
            return { screenshotId, state: 'COMPLETE' };
        }
        if (delivery?.state === 'FAILED') {
            const codes = (delivery.errors || [])
                .map((e) => e.description || e.code)
                .filter(Boolean)
                .join('; ');
            throw new Error(
                codes ||
                    'Review screenshot rejected by Apple (use iPhone size e.g. 1284×2778 px).'
            );
        }
    }

    return { screenshotId, state: 'PROCESSING' };
};

const ensureSubscriptionReviewScreenshot = async (subscriptionId) => {
    const screenshotPath = process.env.APPLE_SUBSCRIPTION_REVIEW_SCREENSHOT_PATH?.trim();
    const existing = await getSubscriptionReviewScreenshot(subscriptionId);

    if (existing?.attributes?.assetDeliveryState?.state === 'COMPLETE') {
        return { skipped: true, reason: 'already_exists', state: 'COMPLETE' };
    }

    if (existing?.attributes?.assetDeliveryState?.state === 'FAILED' && !screenshotPath) {
        const code =
            existing.attributes?.assetDeliveryState?.errors?.[0]?.code ||
            'INVALID_SCREENSHOT';
        throw new Error(
            `${code}: upload a valid iPhone screenshot in App Store Connect or set APPLE_SUBSCRIPTION_REVIEW_SCREENSHOT_PATH in .env (e.g. 1284×2778 px).`
        );
    }

    if (!screenshotPath) {
        return {
            skipped: true,
            required: true,
            reason: 'missing_env_path',
            message:
                'Review screenshot still required. Set APPLE_SUBSCRIPTION_REVIEW_SCREENSHOT_PATH to a real iPhone app screenshot, or upload in App Store Connect → Subscriptions → Review Information.'
        };
    }

    return uploadSubscriptionReviewScreenshot(subscriptionId, screenshotPath);
};

const getMetadataReadiness = async (subscriptionId, groupId) => {
    const locale = getDefaultLocale();
    const [locs, groupLocs, prices, availability, screenshot] = await Promise.all([
        listSubscriptionLocalizations(subscriptionId),
        listSubscriptionGroupLocalizations(groupId),
        listSubscriptionPrices(subscriptionId),
        getSubscriptionAvailability(subscriptionId),
        getSubscriptionReviewScreenshot(subscriptionId)
    ]);

    const blockingReasons = [];

    if (!locs.some((item) => item.attributes?.locale === locale)) {
        blockingReasons.push('Subscription name/description (localization) missing');
    }
    if (!groupLocs.some((item) => item.attributes?.locale === locale)) {
        blockingReasons.push('Subscription group display name missing');
    }
    if (!prices.length) {
        blockingReasons.push('Subscription price not set');
    }
    if (!availability) {
        blockingReasons.push('Territory availability not set');
    }

    const reviewScreenshotState =
        screenshot?.attributes?.assetDeliveryState?.state || (screenshot ? 'UNKNOWN' : 'missing');

    if (!screenshot) {
        blockingReasons.push(
            'Review screenshot required (iPhone dimensions, e.g. 1284×2778 px portrait)'
        );
    } else if (reviewScreenshotState === 'FAILED') {
        const code = screenshot.attributes?.assetDeliveryState?.errors?.[0]?.code;
        blockingReasons.push(
            `Review screenshot invalid${code ? ` (${code})` : ''} — replace with a real iPhone screenshot`
        );
    } else if (reviewScreenshotState !== 'COMPLETE') {
        blockingReasons.push(`Review screenshot not ready yet (${reviewScreenshotState})`);
    }

    return {
        blockingReasons,
        reviewScreenshotState,
        hasSubscriptionLocalization: locs.length > 0,
        hasGroupLocalization: groupLocs.length > 0,
        hasPrice: prices.length > 0,
        hasAvailability: Boolean(availability)
    };
};

const ensureSubscriptionAvailability = async (subscriptionId, territory) => {
    const existing = await getSubscriptionAvailability(subscriptionId);
    if (existing) {
        return { skipped: true, territory, reason: 'already_exists' };
    }

    const created = await apiRequest('POST', '/subscriptionAvailabilities', {
        data: {
            type: 'subscriptionAvailabilities',
            attributes: {
                availableInNewTerritories: true
            },
            relationships: {
                subscription: {
                    data: { type: 'subscriptions', id: String(subscriptionId) }
                },
                availableTerritories: {
                    data: [{ type: 'territories', id: territory }]
                }
            }
        }
    });

    return {
        skipped: false,
        territory,
        availabilityId: created.data?.id
    };
};

/**
 * Add localization, territory availability, and base price so MISSING_METADATA can clear.
 * Idempotent: skips steps already present on App Store Connect.
 */
const completeSubscriptionMetadata = async ({
    subscriptionId,
    name,
    description,
    price,
    locale,
    territory,
    groupId
}) => {
    const id = String(subscriptionId).trim();
    if (!id) {
        throw new Error('Apple subscription ID is required to complete metadata.');
    }

    const resolvedGroupId = groupId || (await resolveSubscriptionGroupId());
    const resolvedTerritory = normalizeTerritory(territory);
    const resolvedLocale = locale || getDefaultLocale();
    const steps = {
        localization: null,
        groupLocalization: null,
        availability: null,
        price: null,
        reviewScreenshot: null
    };
    const errors = [];

    try {
        steps.localization = await ensureSubscriptionLocalization(id, {
            name,
            description: description || name,
            locale: resolvedLocale
        });
    } catch (err) {
        errors.push(`localization: ${err.message}`);
    }

    await sleep(400);

    try {
        steps.groupLocalization = await ensureSubscriptionGroupLocalization(resolvedGroupId, {
            name: process.env.APPLE_SUBSCRIPTION_GROUP_DISPLAY_NAME || name,
            locale: resolvedLocale
        });
    } catch (err) {
        errors.push(`groupLocalization: ${err.message}`);
    }

    await sleep(400);

    try {
        steps.availability = await ensureSubscriptionAvailability(id, resolvedTerritory);
    } catch (err) {
        errors.push(`availability: ${err.message}`);
    }

    await sleep(400);

    try {
        steps.price = await ensureSubscriptionPrice(id, {
            price,
            territory: resolvedTerritory
        });
    } catch (err) {
        errors.push(`price: ${err.message}`);
    }

    await sleep(400);

    try {
        steps.reviewScreenshot = await ensureSubscriptionReviewScreenshot(id);
    } catch (err) {
        errors.push(`reviewScreenshot: ${err.message}`);
    }

    const readiness = await getMetadataReadiness(id, resolvedGroupId);

    if (errors.length >= 5) {
        throw new Error(errors.join(' | '));
    }

    return {
        subscriptionId: id,
        groupId: resolvedGroupId,
        locale: resolvedLocale,
        territory: resolvedTerritory,
        steps,
        errors,
        readiness
    };
};

const createSubscription = async ({
    productId,
    name,
    description,
    price,
    billingPeriod = 'P1M',
    groupLevel = 1
}) => {
    const groupId = await resolveSubscriptionGroupId();

    const created = await apiRequest('POST', '/subscriptions', {
        data: {
            type: 'subscriptions',
            attributes: {
                name: name.slice(0, 64),
                productId,
                subscriptionPeriod: mapBillingPeriod(billingPeriod),
                groupLevel
            },
            relationships: {
                group: {
                    data: { type: 'subscriptionGroups', id: groupId }
                }
            }
        }
    });

    const result = {
        productId: created.data?.attributes?.productId || productId,
        subscriptionId: created.data?.id,
        groupId,
        state: created.data?.attributes?.state || 'MISSING_METADATA'
    };

    if (isAutoCompleteMetadataEnabled() && result.subscriptionId) {
        try {
            const metadata = await completeSubscriptionMetadata({
                subscriptionId: result.subscriptionId,
                name,
                description,
                price
            });
            result.metadata = metadata;
            const refreshed = await findSubscriptionByProductId(result.productId, groupId);
            if (refreshed?.attributes?.state) {
                result.state = refreshed.attributes.state;
            }
        } catch (err) {
            result.metadataWarning = err.message;
        }
    }

    return result;
};

const formatSubscriptionResource = async (resource, groupId) => {
    const attrs = resource.attributes || {};
    const readiness = await getMetadataReadiness(resource.id, groupId);

    return {
        exists: true,
        productId: attrs.productId,
        subscriptionId: resource.id,
        name: attrs.name,
        state: attrs.state || 'UNKNOWN',
        subscriptionPeriod: attrs.subscriptionPeriod,
        groupLevel: attrs.groupLevel,
        familySharable: attrs.familySharable,
        groupId,
        readiness
    };
};

const findSubscriptionByProductId = async (productId, groupId) => {
    let path = `/subscriptionGroups/${encodeURIComponent(groupId)}/subscriptions?limit=200`;

    while (path) {
        const json = await apiRequest('GET', path);
        const match = (json.data || []).find((item) => item.attributes?.productId === productId);
        if (match) return match;

        const next = json.links?.next;
        if (!next) break;
        path = String(next).startsWith('http') ? String(next).replace(API_BASE, '') : next;
    }

    return null;
};

/**
 * Check App Store Connect for a subscription product ID in the configured group.
 */
const verifySubscription = async (productId) => {
    const id = String(productId).trim();
    if (!id) {
        throw new Error('App Store product ID is required.');
    }

    const groupId = await resolveSubscriptionGroupId();
    const match = await findSubscriptionByProductId(id, groupId);

    if (!match) {
        return {
            exists: false,
            productId: id,
            groupId,
            appId: process.env.APPLE_APP_ID || null
        };
    }

    return formatSubscriptionResource(match, groupId);
};

const deleteSubscription = async (subscriptionId) => {
    const id = String(subscriptionId).trim();
    if (!id) {
        throw new Error('App Store subscription resource ID is required.');
    }

    await apiRequest('DELETE', `/subscriptions/${encodeURIComponent(id)}`);
    return { subscriptionId: id, action: 'deleted' };
};

/** Remove from sale in all territories (when DELETE is not allowed). */
const removeSubscriptionFromSale = async (subscriptionId) => {
    const id = String(subscriptionId).trim();
    if (!id) {
        throw new Error('App Store subscription resource ID is required.');
    }

    await apiRequest('POST', '/subscriptionAvailabilities', {
        data: {
            type: 'subscriptionAvailabilities',
            attributes: {
                availableInNewTerritories: false
            },
            relationships: {
                subscription: {
                    data: { type: 'subscriptions', id: String(id) }
                },
                availableTerritories: {
                    data: []
                }
            }
        }
    });

    return { subscriptionId: id, action: 'removed_from_sale' };
};

/**
 * Best-effort App Store removal: DELETE when allowed, else remove from all territories.
 */
const removeSubscriptionFromAppStore = async (productId) => {
    const id = String(productId).trim();
    if (!id) {
        throw new Error('App Store product ID is required.');
    }

    const groupId = await resolveSubscriptionGroupId();
    const match = await findSubscriptionByProductId(id, groupId);

    if (!match) {
        return {
            productId: id,
            groupId,
            skipped: true,
            reason: 'not_found_on_app_store'
        };
    }

    const subscriptionId = match.id;
    const state = match.attributes?.state || 'UNKNOWN';

    const result = {
        productId: id,
        subscriptionId,
        groupId,
        state,
        subscriptionDeleted: false,
        subscriptionRemovedFromSale: false,
        subscriptionDeactivated: false,
        warnings: []
    };

    try {
        await deleteSubscription(subscriptionId);
        result.subscriptionDeleted = true;
        result.subscriptionDeactivated = true;
        return result;
    } catch (err) {
        result.warnings.push(`Delete: ${err.message}`);
    }

    try {
        await removeSubscriptionFromSale(subscriptionId);
        result.subscriptionRemovedFromSale = true;
        result.subscriptionDeactivated = true;
    } catch (err) {
        result.warnings.push(`Remove from sale: ${err.message}`);
        result.warnings.push(
            'If still visible in App Store Connect, remove territories manually (approved subscriptions cannot always be changed via API).'
        );
    }

    return result;
};

module.exports = {
    createSubscription,
    completeSubscriptionMetadata,
    resolveSubscriptionGroupId,
    verifySubscription,
    deleteSubscription,
    removeSubscriptionFromSale,
    removeSubscriptionFromAppStore,
    isAutoCompleteMetadataEnabled
};
