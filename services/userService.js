const User = require('../models/userModel');
const { sequelize } = require('../database/db');
const { sendWaitlistEmail } = require('../utils/emailService');

const joinWaitlist = async (userData) => {
    const { email, device, interest, referredByCode } = userData;

    // Check if user already exists
    let user = await User.findOne({ where: { email } });
    if (user) {
        // If exists, just return status without sending email again
        const status = await getWaitlistStatus(email);
        return { user: status.user, position: status.position, alreadyExists: true };
    }

    const t = await sequelize.transaction();

    try {
        // Create the user
        user = await User.create({
            email,
            device,
            interest,
            referredBy: referredByCode || null
        }, { transaction: t });

        // If referred by someone, increment their count
        if (referredByCode) {
            const referrer = await User.findOne({ where: { referralCode: referredByCode } });
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
    const user = await User.findOne({ where: { email } });
    if (!user) return null;

    const countAhead = await User.count({
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
    return await User.count();
};

const getLeaderboard = async (limit = 10) => {
    return await User.findAll({
        attributes: ['email', 'referralCount', 'referralCode'],
        order: [
            ['referralCount', 'DESC'],
            ['createdAt', 'ASC']
        ],
        limit: limit
    });
};

module.exports = {
    joinWaitlist,
    getWaitlistStatus,
    getTotalSignups,
    getLeaderboard
};
