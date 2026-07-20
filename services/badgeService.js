const { Op } = require('sequelize');
const Badge = require('../models/badgeModel');
const BadgeRule = require('../models/badgeRuleModel');

const getBadgesForChallenge = async (challengeId) => {
    return Badge.findAll({
        where: { challenge_id: challengeId },
        order: [['name', 'ASC']],
        include: [{
            model: BadgeRule,
            as: 'rules',
            where: { challenge_id: challengeId },
            required: false
        }]
    });
};

const createBadge = async (payload) => {
    const challengeId = payload.challenge_id;
    if (!challengeId) {
        throw new Error('challenge_id is required');
    }

    const name = payload.name != null ? String(payload.name).trim() : '';
    if (!name) {
        throw new Error('Badge name is required');
    }

    return Badge.create({
        challenge_id: challengeId,
        name,
        description: payload.description ? String(payload.description).trim() : null,
        icon_url: payload.icon_url ? String(payload.icon_url).trim() : null,
        rarity: ['common', 'rare', 'epic', 'legendary'].includes(payload.rarity) ? payload.rarity : 'common',
        is_active: payload.is_active !== false
    });
};

module.exports = {
    getBadgesForChallenge,
    createBadge
};
