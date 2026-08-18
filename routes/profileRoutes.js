const express = require('express');
const router = express.Router();
const { getProfile, updateProfile, completeOnboarding, getDashboard } = require('../controllers/profileController');
const { protectUser } = require('../middleware/userAuth');

// User Dashboard (placed BEFORE /:userId)
router.get('/dashboard', protectUser, getDashboard);

// Get profile by user ID
router.get('/:userId', getProfile);

// Update profile by user ID
router.put('/:userId', updateProfile);

// Onboarding completion
router.post('/onboarding', completeOnboarding);

module.exports = router;

