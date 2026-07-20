const WaitlistUser = require('../models/waitlistUserModel');
const { sequelize } = require('../database/db');
const { sendWaitlistEmail } = require('../utils/emailService');

const joinWaitlist = async (userData) => {
    const { email, device, interest, referredByCode } = userData;

    // Check if user already exists
    let user = await WaitlistUser.findOne({ where: { email } });
    if (user) {
        // If exists, just return status without sending email again
        const status = await getWaitlistStatus(email);
        return { user: status.user, position: status.position, alreadyExists: true };
    }

    const t = await sequelize.transaction();

    try {
        // Create the user
        user = await WaitlistUser.create({
            email,
            device,
            interest,
            referredBy: referredByCode || null
        }, { transaction: t });

        // If referred by someone, increment their count
        if (referredByCode) {
            const referrer = await WaitlistUser.findOne({ where: { referralCode: referredByCode } });
            if (referrer) {
                referrer.referralCount += 1;
                await referrer.save({ transaction: t });
            }
        }

        await t.commit();

        // Calculate position
        const status = await getWaitlistStatus(email);

        // Send confirmation email asynchronously (don't wait for it)
        sendWaitlistEmail(user.email, user.referralCode, status.position);

        return { user: status.user, position: status.position, alreadyExists: false };
    } catch (error) {
        await t.rollback();
        throw error;
    }
};

const getWaitlistStatus = async (email) => {
    const user = await WaitlistUser.findOne({ where: { email } });
    if (!user) return null;

    const countAhead = await WaitlistUser.count({
        where: sequelize.literal(`
            (referralCount > ${user.referralCount}) OR 
            (referralCount = ${user.referralCount} AND createdAt < '${user.createdAt.toISOString().slice(0, 19).replace('T', ' ')}')
        `)
    });

    return {
        user,
        position: countAhead + 1
    };
};

const getTotalSignups = async () => {
    return await WaitlistUser.count();
};

const getLeaderboard = async (limit = 10) => {
    return await WaitlistUser.findAll({
        attributes: ['email', 'referralCount', 'referralCode'],
        order: [
            ['referralCount', 'DESC'],
            ['createdAt', 'ASC']
        ],
        limit: limit
    });
};

const getAllWaitlistUsers = async () => {
    const users = await WaitlistUser.findAll({
        order: [
            ['referralCount', 'DESC'],
            ['createdAt', 'ASC']
        ]
    });

    // Add rank/position to each user
    return users.map((u, index) => ({
        ...u.toJSON(),
        rank: index + 1
    }));
};

const getRegistrationGrowth = async () => {
    const results = await WaitlistUser.findAll({
        attributes: [
            [sequelize.fn('DATE', sequelize.col('createdAt')), 'date'],
            [sequelize.fn('COUNT', sequelize.col('id')), 'count']
        ],
        group: [sequelize.fn('DATE', sequelize.col('createdAt'))],
        order: [[sequelize.fn('DATE', sequelize.col('createdAt')), 'ASC']],
        limit: 7
    });
    return results;
};

module.exports = {
    joinWaitlist,
    getWaitlistStatus,
    getTotalSignups,
    getLeaderboard,
    getAllWaitlistUsers,
    getRegistrationGrowth
};
