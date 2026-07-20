const SubscriptionPlan = require('../models/subscriptionPlanModel');

const STATUSES = ['draft', 'active', 'inactive', 'archived'];

const parseFeatures = (input) => {
    if (input == null) return null;
    if (Array.isArray(input)) {
        const list = input.map((x) => String(x).trim()).filter(Boolean);
        return list.length ? list : null;
    }
    if (typeof input === 'string') {
        const t = input.trim();
        if (!t) return null;
        try {
            const parsed = JSON.parse(t);
            if (Array.isArray(parsed)) {
                const list = parsed.map((x) => String(x).trim()).filter(Boolean);
                return list.length ? list : null;
            }
        } catch {
            /* comma-separated fallback */
        }
        const list = t.split(',').map((x) => x.trim()).filter(Boolean);
        return list.length ? list : null;
    }
    return null;
};

const validatePayload = (body, { partial } = { partial: false }) => {
    const patch = {};

    if (!partial || body.name !== undefined) {
        const name = body.name != null ? String(body.name).trim() : '';
        if (!name) throw new Error('Plan name is required.');
        patch.name = name.slice(0, 120);
    }

    if (!partial || body.description !== undefined) {
        const description = body.description != null ? String(body.description).trim() : '';
        patch.description = description || null;
    }

    if (!partial || body.status !== undefined) {
        const status = body.status != null ? String(body.status).trim().toLowerCase() : 'draft';
        if (!STATUSES.includes(status)) {
            throw new Error(`Status must be one of: ${STATUSES.join(', ')}`);
        }
        patch.status = status;
    }

    if (!partial || body.free_trials !== undefined) {
        const free_trials = parseInt(body.free_trials, 10);
        patch.free_trials = Number.isFinite(free_trials) && free_trials >= 0 ? free_trials : 0;
    }

    if (!partial || body.price !== undefined) {
        const price = parseFloat(body.price);
        if (!Number.isFinite(price) || price < 0) {
            throw new Error('Price must be a number >= 0.');
        }
        patch.price = Math.round(price * 100) / 100;
    }

    if (!partial || body.currency !== undefined) {
        const currency = body.currency != null ? String(body.currency).trim().toUpperCase() : 'USD';
        if (!/^[A-Z]{3}$/.test(currency)) {
            throw new Error('Currency must be a 3-letter code (e.g. USD).');
        }
        patch.currency = currency;
    }

    if (!partial || body.features !== undefined) {
        patch.features = parseFeatures(body.features);
    }

    if (!partial || body.play_store_sub_id !== undefined) {
        const play_store_sub_id =
            body.play_store_sub_id != null ? String(body.play_store_sub_id).trim() : '';
        patch.play_store_sub_id = play_store_sub_id || null;
    }

    if (!partial || body.app_store_sub_id !== undefined) {
        const app_store_sub_id =
            body.app_store_sub_id != null ? String(body.app_store_sub_id).trim() : '';
        patch.app_store_sub_id = app_store_sub_id || null;
    }

    return patch;
};

const listSubscriptionPlans = async () => {
    return SubscriptionPlan.findAll({
        order: [
            ['status', 'ASC'],
            ['price', 'DESC'],
            ['name', 'ASC']
        ]
    });
};

const getSubscriptionPlanById = async (id) => {
    return SubscriptionPlan.findByPk(id);
};

const createSubscriptionPlan = async (body) => {
    const payload = validatePayload(body);
    return SubscriptionPlan.create(payload);
};

const updateSubscriptionPlan = async (id, body) => {
    const plan = await SubscriptionPlan.findByPk(id);
    if (!plan) throw new Error('Subscription plan not found');
    const payload = validatePayload(body, { partial: true });
    await plan.update(payload);
    return plan;
};

const deleteSubscriptionPlan = async (id) => {
    const plan = await SubscriptionPlan.findByPk(id);
    if (!plan) throw new Error('Subscription plan not found');
    await plan.destroy();
    return { id };
};

module.exports = {
    listSubscriptionPlans,
    getSubscriptionPlanById,
    createSubscriptionPlan,
    updateSubscriptionPlan,
    deleteSubscriptionPlan,
    validatePayload,
    STATUSES
};
