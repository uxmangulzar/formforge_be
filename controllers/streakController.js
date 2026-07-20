const streakService = require('../services/streakService');

const resolveTimeZone = (req) =>
    req.headers['x-timezone'] || req.query.timezone || req.body?.timezone;

const getMyStreak = async (req, res, next) => {
    try {
        const data = await streakService.getStreakSummary(req.user.id, {
            timeZone: resolveTimeZone(req)
        });
        res.status(200).json({ success: true, data });
    } catch (error) {
        next(error);
    }
};

const getStreakCalendar = async (req, res, next) => {
    try {
        const { year, month } = req.query;
        const data = await streakService.getStreakCalendar(req.user.id, {
            year,
            month,
            timeZone: resolveTimeZone(req)
        });
        res.status(200).json({ success: true, data });
    } catch (error) {
        if (error.message.includes('month must be')) {
            res.status(400);
        }
        next(error);
    }
};

module.exports = {
    getMyStreak,
    getStreakCalendar
};
