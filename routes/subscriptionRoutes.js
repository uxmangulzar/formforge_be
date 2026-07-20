const express = require('express');
const router = express.Router();
const { protectUser } = require('../middleware/userAuth');
const {
    getPlans,
    getMySubscription,
    subscribe,
    restore
} = require('../controllers/subscriptionController');

router.get('/plans', getPlans);
router.get('/me', protectUser, getMySubscription);
router.post('/subscribe', protectUser, subscribe);
router.post('/restore', protectUser, restore);

module.exports = router;
