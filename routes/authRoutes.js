const express = require('express');
const router = express.Router();
const { register, verifyEmail, resendVerificationOtp, socialLogin, login, logout, forgotPassword, resetPassword } = require('../controllers/authController');

router.post('/register', register);
router.post('/verify-email', verifyEmail);
router.post('/resend-verification-otp', resendVerificationOtp);
router.post('/social-login', socialLogin);
router.post('/login', login);
router.post('/logout', logout);
router.post('/forgot-password', forgotPassword);
router.post('/reset-password', resetPassword);

module.exports = router;
