const express = require('express');
const router = express.Router();
const { protectUser } = require('../middleware/userAuth');
const {
    getChallenges,
    getChallenge,
    getChallengeLeaderboard,
    joinChallenge,
    getMyChallenges,
    getMyChallengeProgress,
    saveChallengeProgress,
    saveBulkChallengeProgress,
    syncExerciseProgress
} = require('../controllers/challengeController');

router.get('/my', protectUser, getMyChallenges);
router.get('/', getChallenges);
router.get('/:id/leaderboard', getChallengeLeaderboard);
router.post('/:id/join', protectUser, joinChallenge);
router.get('/:id/my-progress', protectUser, getMyChallengeProgress);
router.post('/:id/progress/bulk', protectUser, saveBulkChallengeProgress);
router.post('/:id/progress', protectUser, saveChallengeProgress);
router.patch('/:id/progress/exercise', protectUser, syncExerciseProgress);
router.get('/:id', getChallenge);

module.exports = router;
