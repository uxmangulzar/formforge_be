const userService = require('../services/userService');

const joinWaitlist = async (req, res, next) => {
    try {
        const { email, device, interest, referredByCode } = req.body;

        if (!email) {
            res.status(400);
            throw new Error('Email is required');
        }

        const { user, position, alreadyExists } = await userService.joinWaitlist({
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
        const status = await userService.getWaitlistStatus(email);

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
        const count = await userService.getTotalSignups();
        res.status(200).json({ success: true, count });
    } catch (error) {
        next(error);
    }
};

const getLeaderboard = async (req, res, next) => {
    try {
        const leaderboard = await userService.getLeaderboard(10);
        res.status(200).json({ success: true, data: leaderboard });
    } catch (error) {
        next(error);
    }
};

module.exports = {
    joinWaitlist,
    getStatus,
    getStats,
    getLeaderboard
};
