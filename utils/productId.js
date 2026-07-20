const slugifyProductId = (name) => {
    const slug = String(name || 'plan')
        .toLowerCase()
        .replace(/[^a-z0-9]+/g, '_')
        .replace(/^_+|_+$/g, '')
        .slice(0, 35);
    return slug || 'plan';
};

const toGoogleProductId = (slug) => slug.replace(/-/g, '_').replace(/[^a-z0-9_.]/g, '').slice(0, 40);

const toAppleProductId = (slug) => {
    const prefix = (process.env.APPLE_SUBSCRIPTION_PRODUCT_ID_PREFIX || 'com.formforge.app').replace(
        /\.+$/,
        ''
    );
    const safe = slug.replace(/_/g, '.').replace(/[^a-zA-Z0-9.]/g, '');
    return `${prefix}.${safe}`.slice(0, 100);
};

module.exports = {
    slugifyProductId,
    toGoogleProductId,
    toAppleProductId
};
