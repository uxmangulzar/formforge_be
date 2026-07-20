const authService = require('../services/authService');

const register = async (req, res, next) => {
    try {
        const { email, password } = req.body;

        if (!email || !password) {
            res.status(400);
            throw new Error('Please provide email and password');
        }

        const user = await authService.registerUser({ email, password });

        res.status(201).json({
            success: true,
            message: 'User registered successfully. Please verify your email with the OTP sent to your inbox.',
            data: user
        });
    } catch (error) {
        next(error);
    }
};

const login = async (req, res, next) => {
    try {
        const { email, password } = req.body;

        if (!email || !password) {
            res.status(400);
            throw new Error('Please provide email and password');
        }

        const user = await authService.loginUser({ email, password });

        res.status(200).json({
            success: true,
            message: 'Login successful',
            data: user
        });
    } catch (error) {
        next(error);
    }
};

const verifyEmail = async (req, res, next) => {
    try {
        const { email, otp } = req.body;

        if (!email || !otp) {
            res.status(400);
            throw new Error('Please provide email and OTP');
        }

        const user = await authService.verifyEmail({ email, otp });

        res.status(200).json({
            success: true,
            message: 'Email verified successfully',
            data: user
        });
    } catch (error) {
        next(error);
    }
};

const resendVerificationOtp = async (req, res, next) => {
    try {
        const { email } = req.body;

        if (!email) {
            res.status(400);
            throw new Error('Please provide email');
        }

        const result = await authService.resendVerificationOtp({ email });

        res.status(200).json({
            success: true,
            message: 'A new verification OTP has been sent to your email.',
            data: result
        });
    } catch (error) {
        next(error);
    }
};

const socialLogin = async (req, res, next) => {
    try {
        const { provider, email, full_name, avatar_url } = req.body;

        if (!provider || !email) {
            res.status(400);
            throw new Error('Please provide provider and email');
        }

        const user = await authService.socialLoginUser({
            provider: String(provider).trim().toLowerCase(),
            email,
            full_name,
            avatar_url
        });

        res.status(user.isNewUser ? 201 : 200).json({
            success: true,
            message: user.isNewUser ? 'Account created successfully' : 'Login successful',
            data: user
        });
    } catch (error) {
        next(error);
    }
};

const logout = async (req, res, next) => {
    try {
        res.status(200).json({
            success: true,
            message: 'Logged out successfully'
        });
    } catch (error) {
        next(error);
    }
};

const forgotPassword = async (req, res, next) => {
    try {
        const { email } = req.body;

        if (!email) {
            res.status(400);
            throw new Error('Please provide an email');
        }

        const result = await authService.forgotPassword(email);

        res.status(200).json({
            success: true,
            message: 'Password reset OTP has been sent to your email.',
            data: result
        });
    } catch (error) {
        next(error);
    }
};

const resetPassword = async (req, res, next) => {
    try {
        const { otp, password } = req.body;

        if (!otp || !password) {
            res.status(400);
            throw new Error('Please provide OTP and new password');
        }

        await authService.resetPassword(otp, password);

        res.status(200).json({
            success: true,
            message: 'Password reset successful'
        });
    } catch (error) {
        next(error);
    }
};

module.exports = {
    register,
    verifyEmail,
    resendVerificationOtp,
    socialLogin,
    login,
    logout,
    forgotPassword,
    resetPassword
};
