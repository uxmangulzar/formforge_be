const waitlistService = require('../services/waitlistService');

const joinWaitlist = async (req, res, next) => {
    try {
        const { email, device, interest, referredByCode } = req.body;

        if (!email) {
            res.status(400);
            throw new Error('Email is required');
        }

        const { user, position, alreadyExists } = await waitlistService.joinWaitlist({
            email,
            device,
            interest,
            referredByCode
        });

        res.status(alreadyExists ? 200 : 201).json({
            success: true,
            message: alreadyExists ? 'Welcome back!' : 'Successfully joined the waitlist!',
            data: {
                user,
                position
            }
        });
    } catch (error) {
        next(error);
    }
};

const getStatus = async (req, res, next) => {
    try {
        const { email } = req.params;
        const status = await waitlistService.getWaitlistStatus(email);

        if (!status) {
            return res.status(404).json({ success: false, message: 'User not found' });
        }

        res.status(200).json({ success: true, data: status });
    } catch (error) {
        next(error);
    }
};

const getStats = async (req, res, next) => {
    try {
        const count = await waitlistService.getTotalSignups();
        res.status(200).json({ success: true, count });
    } catch (error) {
        next(error);
    }
};

const getLeaderboard = async (req, res, next) => {
    try {
        const leaderboard = await waitlistService.getLeaderboard(10);
        res.status(200).json({ success: true, data: leaderboard });
    } catch (error) {
        next(error);
    }
};

const getAllUsers = async (req, res, next) => {
    try {
        const users = await waitlistService.getAllWaitlistUsers();
        res.status(200).json({ success: true, data: users });
    } catch (error) {
        next(error);
    }
};

const getGrowthData = async (req, res, next) => {
    try {
        const growth = await waitlistService.getRegistrationGrowth();
        res.status(200).json({ success: true, data: growth });
    } catch (error) {
        next(error);
    }
};

module.exports = {
    joinWaitlist,
    getStatus,
    getStats,
    getLeaderboard,
    getAllUsers,
    getGrowthData
};
