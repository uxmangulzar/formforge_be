const toGoogleMoney = (amount, currencyCode = 'USD') => {
    const fixed = Math.round(Number(amount) * 100) / 100;
    if (!Number.isFinite(fixed) || fixed < 0) {
        throw new Error('Invalid price for Google Play Money format.');
    }
    const units = Math.floor(fixed);
    const nanos = Math.round((fixed - units) * 1e9);
    return {
        currencyCode: currencyCode.toUpperCase(),
        units: String(units),
        nanos
    };
};

module.exports = { toGoogleMoney };
