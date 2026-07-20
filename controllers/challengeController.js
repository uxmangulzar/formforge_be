const mobileChallengeService = require('../services/mobileChallengeService');

const getChallenges = async (req, res, next) => {
    try {
        const { page, limit, active } = req.query;
        const result = await mobileChallengeService.listPublicChallenges({ page, limit, active });
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

const getChallenge = async (req, res, next) => {
    try {
        const data = await mobileChallengeService.getPublicChallengeById(req.params.id);
        if (!data) {
            res.status(404);
            throw new Error('Challenge not found');
        }
        res.status(200).json({ success: true, data });
    } catch (error) {
        next(error);
    }
};

const getChallengeLeaderboard = async (req, res, next) => {
    try {
        const result = await mobileChallengeService.getChallengeLeaderboard(req.params.id, req.query);
        if (!result) {
            res.status(404);
            throw new Error('Challenge not found');
        }
        res.status(200).json({
            success: true,
            challenge: result.challenge,
            count: result.data.length,
            pagination: result.pagination,
            data: result.data
        });
    } catch (error) {
        next(error);
    }
};

const joinChallenge = async (req, res, next) => {
    try {
        const data = await mobileChallengeService.joinChallenge(req.user.id, req.params.id);
        res.status(201).json({
            success: true,
            message: 'Joined challenge successfully',
            data
        });
    } catch (error) {
        if (
            error.message.includes('already joined') ||
            error.message.includes('ended') ||
            error.message.includes('not available')
        ) {
            res.status(400);
        }
        next(error);
    }
};

const getMyChallenges = async (req, res, next) => {
    try {
        const { page, limit, status } = req.query;
        const result = await mobileChallengeService.listMyChallenges(req.user.id, { page, limit, status });
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

const getMyChallengeProgress = async (req, res, next) => {
    try {
        const data = await mobileChallengeService.getMyChallengeProgress(req.user.id, req.params.id);
        if (!data) {
            res.status(404);
            throw new Error('You have not joined this challenge');
        }
        res.status(200).json({ success: true, data });
    } catch (error) {
        next(error);
    }
};

const progressSaveErrors = (error, res) => {
    if (
        error.message.includes('Join this challenge') ||
        error.message.includes('not started') ||
        error.message.includes('ended') ||
        error.message.includes('unlocked') ||
        error.message.includes('already completed') ||
        error.message.includes('no longer active') ||
        error.message.includes('required') ||
        error.message.includes('Maximum 50')
    ) {
        res.status(400);
    }
};

const saveChallengeProgress = async (req, res, next) => {
    try {
        const result = await mobileChallengeService.syncExerciseProgress(
            req.user.id,
            req.params.id,
            req.body
        );
        res.status(200).json({
            success: true,
            message: 'Progress saved',
            data: result.progress,
            badges_earned: result.badges_earned
        });
    } catch (error) {
        progressSaveErrors(error, res);
        next(error);
    }
};

const saveBulkChallengeProgress = async (req, res, next) => {
    try {
        const result = await mobileChallengeService.syncBulkExerciseProgress(
            req.user.id,
            req.params.id,
            req.body
        );
        res.status(200).json({
            success: true,
            message: 'Progress saved',
            saved_count: result.saved_count,
            data: result.progress,
            badges_earned: result.badges_earned
        });
    } catch (error) {
        progressSaveErrors(error, res);
        next(error);
    }
};

const syncExerciseProgress = saveChallengeProgress;

module.exports = {
    getChallenges,
    getChallenge,
    getChallengeLeaderboard,
    joinChallenge,
    getMyChallenges,
    getMyChallengeProgress,
    saveChallengeProgress,
    saveBulkChallengeProgress,
    syncExerciseProgress
};
