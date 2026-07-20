const User = require('../models/userModel');
const Profile = require('../models/profileModel');
const generateToken = require('../utils/generateToken');
const { sendVerificationOtpEmail, sendPasswordResetOtpEmail } = require('../utils/emailService');
const crypto = require('crypto');

const formatUserResponse = (userWithProfile) => {
    const userResponse = userWithProfile.toJSON();
    delete userResponse.password;
    delete userResponse.resetPasswordToken;
    delete userResponse.resetPasswordExpire;
    return userResponse;
};

const issueVerificationOtp = async (user) => {
    const otp = user.getEmailVerificationOtp();
    await user.save();
    sendVerificationOtpEmail(user.email, otp);
    return otp;
};

const registerUser = async (userData) => {
    const { email, password } = userData;

    let user = await User.findOne({ where: { email } });
    if (user) {
        if (user.is_verified) {
            throw new Error('User already exists');
        }

        user.password = password;
        await issueVerificationOtp(user);

        const userWithProfile = await User.findByPk(user.id, {
            include: [{ model: Profile, as: 'profile' }]
        });

        return {
            ...formatUserResponse(userWithProfile),
            requiresVerification: true
        };
    }

    user = await User.create({
        email,
        password,
        is_verified: false
    });

    await Profile.create({ user_id: user.id });
    await issueVerificationOtp(user);

    const userWithProfile = await User.findByPk(user.id, {
        include: [{ model: Profile, as: 'profile' }]
    });

    return {
        ...formatUserResponse(userWithProfile),
        requiresVerification: true
    };
};

const verifyEmail = async ({ email, otp }) => {
    const user = await User.findOne({
        where: { email },
        include: [{ model: Profile, as: 'profile' }]
    });

    if (!user) {
        throw new Error('User not found with this email');
    }

    if (user.is_verified) {
        throw new Error('Email is already verified');
    }

    if (!user.resetPasswordToken || !user.resetPasswordExpire) {
        throw new Error('No verification OTP found. Please sign up again.');
    }

    if (user.resetPasswordExpire < Date.now()) {
        throw new Error('OTP has expired. Please request a new OTP.');
    }

    const hashedOtp = crypto.createHash('sha256').update(String(otp).trim()).digest('hex');
    if (hashedOtp !== user.resetPasswordToken) {
        throw new Error('Invalid OTP');
    }

    user.is_verified = true;
    user.resetPasswordToken = null;
    user.resetPasswordExpire = null;
    await user.save();

    return {
        ...formatUserResponse(user),
        token: generateToken(user.id)
    };
};

const resendVerificationOtp = async ({ email }) => {
    const user = await User.findOne({ where: { email } });

    if (!user) {
        throw new Error('User not found with this email');
    }

    if (user.is_verified) {
        throw new Error('Email is already verified');
    }

    if (user.role !== 'user') {
        throw new Error('Verification OTP can only be resent for app user accounts');
    }

    await issueVerificationOtp(user);

    return { email: user.email };
};

const SOCIAL_PROVIDERS = ['google', 'apple'];

const syncSocialProfile = async (profile, { full_name, avatar_url }) => {
    if (!profile) return;

    let changed = false;
    if (full_name && profile.full_name !== full_name) {
        profile.full_name = full_name;
        changed = true;
    }
    if (avatar_url && profile.avatar_url !== avatar_url) {
        profile.avatar_url = avatar_url;
        changed = true;
    }
    if (changed) {
        await profile.save();
    }
};

const markUserVerified = async (user) => {
    let changed = false;
    if (!user.is_verified) {
        user.is_verified = true;
        changed = true;
    }
    if (user.resetPasswordToken || user.resetPasswordExpire) {
        user.resetPasswordToken = null;
        user.resetPasswordExpire = null;
        changed = true;
    }
    if (changed) {
        await user.save();
    }
};

const socialLoginUser = async (socialData) => {
    const { provider, email, full_name, avatar_url } = socialData;
    const normalizedEmail = String(email).trim().toLowerCase();

    if (!SOCIAL_PROVIDERS.includes(provider)) {
        throw new Error('provider must be google or apple');
    }

    let user = await User.findOne({
        where: { email: normalizedEmail },
        include: [{ model: Profile, as: 'profile' }]
    });

    if (user) {
        if (user.role !== 'user') {
            throw new Error('Social login is not available for this account');
        }
        if (user.status !== 'active') {
            throw new Error('Account is not active');
        }

        await markUserVerified(user);
        await syncSocialProfile(user.profile, { full_name, avatar_url });

        const userWithProfile = await User.findByPk(user.id, {
            include: [{ model: Profile, as: 'profile' }]
        });

        return {
            ...formatUserResponse(userWithProfile),
            token: generateToken(user.id),
            isNewUser: false,
            provider
        };
    }

    const randomPassword = crypto.randomBytes(32).toString('hex');

    user = await User.create({
        email: normalizedEmail,
        password: randomPassword,
        is_verified: true,
        role: 'user',
        status: 'active'
    });

    await Profile.create({
        user_id: user.id,
        full_name: full_name || null,
        avatar_url: avatar_url || null
    });

    const userWithProfile = await User.findByPk(user.id, {
        include: [{ model: Profile, as: 'profile' }]
    });

    return {
        ...formatUserResponse(userWithProfile),
        token: generateToken(user.id),
        isNewUser: true,
        provider
    };
};

const loginUser = async (userData) => {
    const { email, password } = userData;

    const user = await User.findOne({
        where: { email },
        include: [{ model: Profile, as: 'profile' }]
    });

    if (user && (await user.comparePassword(password))) {
        if (user.role === 'user' && user.is_verified === false) {
            throw new Error('Please verify your email before logging in');
        }

        return {
            ...formatUserResponse(user),
            token: generateToken(user.id)
        };
    }

    throw new Error('Invalid email or password');
};

const forgotPassword = async (email) => {
    const user = await User.findOne({ where: { email } });

    if (!user) {
        throw new Error('User not found with this email');
    }

    const otp = user.getPasswordResetOtp();
    await user.save();
    sendPasswordResetOtpEmail(user.email, otp);

    return { email: user.email };
};

const resetPassword = async (resetToken, newPassword) => {
    const hashedToken = crypto.createHash('sha256').update(String(resetToken).trim()).digest('hex');

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
    verifyEmail,
    resendVerificationOtp,
    socialLoginUser,
    loginUser,
    forgotPassword,
    resetPassword,
    changePassword
};
