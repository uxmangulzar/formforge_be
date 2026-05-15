const Profile = require('../models/profileModel');
const User = require('../models/userModel');
const { sequelize } = require('../database/db');

const getProfileByUserId = async (userId) => {
    const profile = await Profile.findOne({
        where: { user_id: userId },
        include: [{ 
            model: User, 
            as: 'user', 
            attributes: ['email', 'referral_code', 'role', 'status', 'is_profile_completed'] 
        }]
    });
    return profile;
};

const updateProfile = async (userId, updateData) => {
    const profile = await Profile.findOne({ where: { user_id: userId } });
    
    if (!profile) {
        throw new Error('Profile not found');
    }

    // Update fields
    Object.assign(profile, updateData);
    await profile.save();

    // If profile is updated, we might want to set is_profile_completed to true in User table
    // But usually this happens after specific onboarding steps.
    // For now, just return updated profile.
    return profile;
};

const completeOnboarding = async (userId, onboardingData) => {
    const t = await sequelize.transaction();

    try {
        const profile = await Profile.findOne({ where: { user_id: userId } });
        if (!profile) {
            throw new Error('Profile not found');
        }

        // Update profile fields
        Object.assign(profile, onboardingData);
        await profile.save({ transaction: t });

        // Update user status
        const user = await User.findByPk(userId);
        if (user) {
            user.is_profile_completed = true;
            await user.save({ transaction: t });
        }

        await t.commit();
        return profile;
    } catch (error) {
        await t.rollback();
        throw error;
    }
};

module.exports = {
    getProfileByUserId,
    updateProfile,
    completeOnboarding
};
