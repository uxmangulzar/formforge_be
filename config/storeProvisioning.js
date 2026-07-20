const fs = require('fs');
const path = require('path');

const readJsonFile = (filePath) => {
    const resolved = path.resolve(filePath);
    return JSON.parse(fs.readFileSync(resolved, 'utf8'));
};

const resolveJsonFilePath = (value) => {
    const trimmed = String(value).trim();
    if (!trimmed) return null;
    if (path.isAbsolute(trimmed)) return trimmed;
    return path.resolve(process.cwd(), trimmed);
};

const loadGoogleCredentials = () => {
    const inline = process.env.GOOGLE_PLAY_SERVICE_ACCOUNT_JSON?.trim();
    const fileFromPath = process.env.GOOGLE_PLAY_SERVICE_ACCOUNT_PATH?.trim();

    if (inline) {
        if (inline.startsWith('{')) {
            try {
                return JSON.parse(inline);
            } catch {
                throw new Error(
                    'GOOGLE_PLAY_SERVICE_ACCOUNT_JSON is not valid JSON. Paste the full service account JSON, or set it to a file path like google_service.json.'
                );
            }
        }

        const filePath = resolveJsonFilePath(inline);
        if (fs.existsSync(filePath)) {
            return readJsonFile(filePath);
        }

        throw new Error(
            `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON file not found: ${inline}. Place the JSON key file in the project root or use GOOGLE_PLAY_SERVICE_ACCOUNT_PATH.`
        );
    }

    if (fileFromPath) {
        return readJsonFile(resolveJsonFilePath(fileFromPath));
    }

    return null;
};

const resolveProjectPath = (filePath) => {
    const trimmed = String(filePath).trim();
    if (!trimmed) return null;
    if (path.isAbsolute(trimmed)) return trimmed;

    const fromCwd = path.resolve(process.cwd(), trimmed);
    if (fs.existsSync(fromCwd)) return fromCwd;

    return path.resolve(__dirname, '..', trimmed);
};

const loadApplePrivateKey = () => {
    if (process.env.APPLE_PRIVATE_KEY) {
        return process.env.APPLE_PRIVATE_KEY.replace(/\\n/g, '\n');
    }
    if (process.env.APPLE_PRIVATE_KEY_PATH) {
        const keyPath = resolveProjectPath(process.env.APPLE_PRIVATE_KEY_PATH);
        if (!keyPath || !fs.existsSync(keyPath)) {
            throw new Error(
                `Apple private key file not found: ${process.env.APPLE_PRIVATE_KEY_PATH}. Place the .p8 file in the project root.`
            );
        }
        return fs.readFileSync(keyPath, 'utf8');
    }
    return null;
};

const isGooglePlayConfigured = () =>
    Boolean(process.env.GOOGLE_PLAY_PACKAGE_NAME && loadGoogleCredentials());

const isAppleAppStoreConfigured = () =>
    Boolean(
        process.env.APPLE_ISSUER_ID &&
            process.env.APPLE_KEY_ID &&
            loadApplePrivateKey() &&
            process.env.APPLE_APP_ID &&
            (process.env.APPLE_SUBSCRIPTION_GROUP_ID || process.env.APPLE_AUTO_CREATE_SUBSCRIPTION_GROUP === 'true')
    );

const getStoreProvisioningStatus = () => ({
    googlePlay: {
        configured: isGooglePlayConfigured(),
        packageName: process.env.GOOGLE_PLAY_PACKAGE_NAME || null
    },
    appleAppStore: {
        configured: isAppleAppStoreConfigured(),
        appId: process.env.APPLE_APP_ID || null,
        subscriptionGroupId: process.env.APPLE_SUBSCRIPTION_GROUP_ID || null
    }
});

module.exports = {
    loadGoogleCredentials,
    loadApplePrivateKey,
    resolveProjectPath,
    isGooglePlayConfigured,
    isAppleAppStoreConfigured,
    getStoreProvisioningStatus
};
