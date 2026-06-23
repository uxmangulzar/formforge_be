const express = require('express');
const router = express.Router();
const { protectUser } = require('../middleware/userAuth');
const { getMyStreak, getStreakCalendar } = require('../controllers/streakController');

router.use(protectUser);

router.get('/me', getMyStreak);
router.get('/calendar', getStreakCalendar);

module.exports = router;
