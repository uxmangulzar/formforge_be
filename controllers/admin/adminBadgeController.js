const badgeService = require('../../services/badgeService');

const getAdminBadges = async (req, res, next) => {
    try {
        const challengeId = req.query.challenge_id;
        if (!challengeId) {
            return res.status(400).json({
                success: false,
                message: 'Query parameter challenge_id is required (badges are per challenge).'
            });
        }
        const data = await badgeService.getBadgesForChallenge(challengeId);
        res.status(200).json({ success: true, count: data.length, data });
    } catch (error) {
        next(error);
    }
};

const createAdminBadge = async (req, res, next) => {
    try {
        if (!req.body.challenge_id) {
            return res.status(400).json({
                success: false,
                message: 'challenge_id is required in body (badge belongs to one challenge).'
            });
        }
        const data = await badgeService.createBadge(req.body);
        res.status(201).json({ success: true, message: 'Badge created', data });
    } catch (error) {
        next(error);
    }
};

module.exports = {
    getAdminBadges,
    createAdminBadge
};
