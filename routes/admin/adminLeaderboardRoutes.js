const express = require('express');
const router = express.Router();
const { protectAdmin } = require('../../middleware/adminAuth');
const { getUsersLeaderboard } = require('../../controllers/admin/adminLeaderboardController');

router.use(protectAdmin);

router.get('/users', getUsersLeaderboard);

module.exports = router;
