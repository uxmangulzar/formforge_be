const express = require('express');
const router = express.Router();
const { adminLogin, changePassword } = require('../../controllers/admin/adminAuthController');
const { protectAdmin } = require('../../middleware/adminAuth');

// Admin Auth Routes
router.post('/login', adminLogin);
router.patch('/password', protectAdmin, changePassword);

module.exports = router;
