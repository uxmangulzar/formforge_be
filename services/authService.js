const User = require('../models/userModel');
const Profile = require('../models/profileModel');
const generateToken = require('../utils/generateToken');

const registerUser = async (userData) => {
    const { email, password } = userData;

    // Check if user exists
    const userExists = await User.findOne({ where: { email } });
    if (userExists) {
        throw new Error('User already exists');
    }

    // Create user
    const user = await User.create({
        email,
        password
    });

    // Create an initial empty profile for the user
    await Profile.create({ user_id: user.id });

    if (user) {
        // Re-fetch with profile
        const userWithProfile = await User.findByPk(user.id, {
            include: [{ model: Profile, as: 'profile' }]
        });

        const userResponse = userWithProfile.toJSON();
        delete userResponse.password;
        
        return {
            ...userResponse,
            token: generateToken(user.id)
        };
    } else {
        throw new Error('Invalid user data');
    }
};

const loginUser = async (userData) => {
    const { email, password } = userData;

    // Find user with profile
    const user = await User.findOne({ 
        where: { email },
        include: [{ model: Profile, as: 'profile' }]
    });

    if (user && (await user.comparePassword(password))) {
        const userResponse = user.toJSON();
        delete userResponse.password;

        return {
            ...userResponse,
            token: generateToken(user.id)
        };
    } else {
        throw new Error('Invalid email or password');
    }
};

const forgotPassword = async (email) => {
    const user = await User.findOne({ where: { email } });

    if (!user) {
        throw new Error('User not found with this email');
    }

    // Get reset token
    const resetToken = user.getResetPasswordToken();

    // Save user with token and expiry
    await user.save();

    return resetToken;
};

const resetPassword = async (resetToken, newPassword) => {
    // Hash token to compare with DB
    const hashedToken = require('crypto').createHash('sha256').update(resetToken).digest('hex');

    const user = await User.findOne({
        where: {
            resetPasswordToken: hashedToken
        }
    });

    if (!user) {
        throw new Error('Invalid OTP/Token');
    }

    // Check if expired
    if (user.resetPasswordExpire < Date.now()) {
        throw new Error('Token has expired');
    }

    // Set new password
    user.password = newPassword;
    user.resetPasswordToken = null;
    user.resetPasswordExpire = null;

    await user.save();

    return user;
};

const changePassword = async (userId, currentPassword, newPassword) => {
    if (!currentPassword || !newPassword) {
        throw new Error('Current and new password are required');
    }
    if (String(newPassword).length < 6) {
        throw new Error('New password must be at least 6 characters');
    }

    const user = await User.findByPk(userId);
    if (!user || user.role !== 'admin') {
        throw new Error('Admin account not found');
    }

    const valid = await user.comparePassword(currentPassword);
    if (!valid) {
        throw new Error('Current password is incorrect');
    }

    user.password = newPassword;
    await user.save();
    return { id: user.id, email: user.email };
};

module.exports = {
    registerUser,
    loginUser,
    forgotPassword,
    resetPassword,
    changePassword
};
