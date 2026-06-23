const express = require('express');
const router = express.Router();
const { protectAdmin } = require('../../middleware/adminAuth');
const {
    getAdminChallenges,
    getAdminChallengeById,
    getAdminChallengeLeaderboard,
    createAdminChallenge,
    updateAdminChallenge,
    deleteAdminChallenge
} = require('../../controllers/admin/adminChallengeController');

router.use(protectAdmin);
router.get('/', getAdminChallenges);
router.post('/', createAdminChallenge);
router.get('/:id/leaderboard', getAdminChallengeLeaderboard);
router.get('/:id', getAdminChallengeById);
router.put('/:id', updateAdminChallenge);
router.delete('/:id', deleteAdminChallenge);

module.exports = router;
