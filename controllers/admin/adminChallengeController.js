const challengeService = require('../../services/challengeService');

// @desc    List all challenges (admin — all statuses)
// @route   GET /api/admin/challenges
// @access  Private/Admin
const getAdminChallenges = async (req, res, next) => {
    try {
        const data = await challengeService.getAllChallengesForAdmin();
        res.status(200).json({
            success: true,
            count: data.length,
            data
        });
    } catch (error) {
        next(error);
    }
};

// @desc    Create challenge (optional nested stages + exercises)
// @route   POST /api/admin/challenges
// @access  Private/Admin
const createAdminChallenge = async (req, res, next) => {
    try {
        const data = await challengeService.createChallenge(req.body);
        res.status(201).json({
            success: true,
            message: 'Challenge created successfully',
            data
        });
    } catch (error) {
        next(error);
    }
};

// @route   GET /api/admin/challenges/:id
const getAdminChallengeById = async (req, res, next) => {
    try {
        const data = await challengeService.getChallengeByIdForAdmin(req.params.id);
        if (!data) {
            res.status(404);
            throw new Error('Challenge not found');
        }
        res.status(200).json({ success: true, data });
    } catch (error) {
        next(error);
    }
};

// @route   PUT /api/admin/challenges/:id
const updateAdminChallenge = async (req, res, next) => {
    try {
        const data = await challengeService.updateChallenge(req.params.id, req.body);
        res.status(200).json({
            success: true,
            message: 'Challenge updated successfully',
            data
        });
    } catch (error) {
        if (error.message === 'Challenge not found') {
            res.status(404);
        }
        next(error);
    }
};

// @route   DELETE /api/admin/challenges/:id
const deleteAdminChallenge = async (req, res, next) => {
    try {
        await challengeService.deleteChallenge(req.params.id);
        res.status(200).json({ success: true, message: 'Challenge deleted successfully' });
    } catch (error) {
        if (error.message === 'Challenge not found') {
            res.status(404);
        }
        next(error);
    }
};

module.exports = {
    getAdminChallenges,
    getAdminChallengeById,
    createAdminChallenge,
    updateAdminChallenge,
    deleteAdminChallenge
};
