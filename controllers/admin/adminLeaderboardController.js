const leaderboardService = require('../../services/leaderboardService');

const getUsersLeaderboard = async (req, res, next) => {
    try {
        const data = await leaderboardService.getAppUsersLeaderboard(req.query.limit);
        res.status(200).json({
            success: true,
            count: data.length,
            data
        });
    } catch (error) {
        next(error);
    }
};

module.exports = {
    getUsersLeaderboard
};
