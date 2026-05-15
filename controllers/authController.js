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
            message: 'User registered successfully',
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

        const resetToken = await authService.forgotPassword(email);

        // In a real app, you would send this token via email.
        // For now, we return it in the response for testing.
        res.status(200).json({
            success: true,
            message: 'Token generated successfully',
            resetToken
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
    login,
    logout,
    forgotPassword,
    resetPassword
};
