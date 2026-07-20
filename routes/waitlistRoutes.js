const express = require('express');
const router = express.Router();
const { joinWaitlist, getStatus, getStats, getLeaderboard, getAllUsers, getGrowthData } = require('../controllers/waitlistController');

const { protectAdmin } = require('../middleware/adminAuth');

// Join Waitlist (Optional referredByCode in body)
router.post('/join', joinWaitlist);

// Get User Status (Position/Referrals)
router.get('/status/:email', getStatus);

// Get Social Proof Stats (Total Signups)
router.get('/stats', getStats);

// Get Leaderboard (Top 10)
router.get('/leaderboard', getLeaderboard);

// Admin Routes (Protected)
router.get('/', protectAdmin, getAllUsers);
router.get('/analytics/growth', protectAdmin, getGrowthData);

module.exports = router;
