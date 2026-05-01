const express = require('express');
const router = express.Router();
const { joinWaitlist, getStatus, getStats, getLeaderboard } = require('../controllers/userController');

// Join Waitlist (Optional referredByCode in body)
router.post('/join', joinWaitlist);

// Get User Status (Position/Referrals)
router.get('/status/:email', getStatus);

// Get Social Proof Stats (Total Signups)
router.get('/stats', getStats);

// Get Leaderboard (Top 10)
router.get('/leaderboard', getLeaderboard);

module.exports = router;
