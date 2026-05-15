const profileService = require('../services/profileService');

const getProfile = async (req, res, next) => {
    try {
        const { userId } = req.params;
        const profile = await profileService.getProfileByUserId(userId);

        if (!profile) {
            res.status(404);
            throw new Error('Profile not found');
        }

        res.status(200).json({
            success: true,
            data: profile
        });
    } catch (error) {
        next(error);
    }
};

const updateProfile = async (req, res, next) => {
    try {
        const { userId } = req.params;
        const updateData = req.body;

        const updatedProfile = await profileService.updateProfile(userId, updateData);

        res.status(200).json({
            success: true,
            message: 'Profile updated successfully',
            data: updatedProfile
        });
    } catch (error) {
        next(error);
    }
};

const completeOnboarding = async (req, res, next) => {
    try {
        const { userId } = req.body;
        const onboardingData = req.body;

        if (!userId) {
            res.status(400);
            throw new Error('UserId is required');
        }

        const updatedProfile = await profileService.completeOnboarding(userId, onboardingData);

        res.status(200).json({
            success: true,
            message: 'Onboarding completed successfully',
            data: updatedProfile
        });
    } catch (error) {
        next(error);
    }
};

module.exports = {
    getProfile,
    updateProfile,
    completeOnboarding
};
