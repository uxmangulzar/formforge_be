const workoutService = require('../services/workoutService');

const createWorkout = async (req, res, next) => {
    try {
        const timeZone = req.headers['x-timezone'] || req.query.timezone || req.body?.timezone;
        const result = await workoutService.createWorkoutSession(req.user.id, req.body, { timeZone });
        res.status(201).json({
            success: true,
            message: 'Workout logged successfully',
            data: result.session,
            streak: result.streak
        });
    } catch (error) {
        if (
            error.message.includes('required') ||
            error.message.includes('not found') ||
            error.message.includes('must be') ||
            error.message.includes('Invalid')
        ) {
            res.status(400);
        }
        next(error);
    }
};

const getWorkouts = async (req, res, next) => {
    try {
        const { page, limit, exercise_id, mode, challenge_id, from, to } = req.query;
        const result = await workoutService.listWorkoutSessions(req.user.id, {
            page,
            limit,
            exercise_id,
            mode,
            challenge_id,
            from,
            to
        });
        res.status(200).json({
            success: true,
            count: result.data.length,
            pagination: result.pagination,
            data: result.data
        });
    } catch (error) {
        next(error);
    }
};

const getWorkoutStats = async (req, res, next) => {
    try {
        const { exercise_id, mode } = req.query;
        const data = await workoutService.getWorkoutStats(req.user.id, { exercise_id, mode });
        res.status(200).json({ success: true, data });
    } catch (error) {
        next(error);
    }
};

const getWorkout = async (req, res, next) => {
    try {
        const data = await workoutService.getWorkoutSessionById(req.user.id, req.params.id);
        if (!data) {
            res.status(404);
            throw new Error('Workout session not found');
        }
        res.status(200).json({ success: true, data });
    } catch (error) {
        next(error);
    }
};

module.exports = {
    createWorkout,
    getWorkouts,
    getWorkoutStats,
    getWorkout
};
