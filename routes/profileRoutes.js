const express = require('express');
const router = express.Router();
const { getProfile, updateProfile, completeOnboarding } = require('../controllers/profileController');

// Get profile by user ID
router.get('/:userId', getProfile);

// Update profile by user ID
router.put('/:userId', updateProfile);

// Onboarding completion
router.post('/onboarding', completeOnboarding);

module.exports = router;
