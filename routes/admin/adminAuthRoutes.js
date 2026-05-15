const express = require('express');
const router = express.Router();
const { adminLogin } = require('../../controllers/admin/adminAuthController');

// Admin Auth Routes
router.post('/login', adminLogin);

module.exports = router;
