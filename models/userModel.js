const { DataTypes } = require('sequelize');
const { sequelize } = require('../database/db');
const bcrypt = require('bcryptjs');
const crypto = require('crypto');

const User = sequelize.define('User', {
    id: {
        type: DataTypes.CHAR(36),
        primaryKey: true,
        defaultValue: DataTypes.UUIDV4
    },
    email: {
        type: DataTypes.STRING,
        allowNull: false,
        unique: true,
        validate: {
            isEmail: true
        }
    },
    password: {
        type: DataTypes.STRING,
        allowNull: false
    },
    referral_code: {
        type: DataTypes.STRING,
        unique: true
    },
    is_verified: {
        type: DataTypes.BOOLEAN,
        defaultValue: false
    },
    is_profile_completed: {
        type: DataTypes.BOOLEAN,
        defaultValue: false
    },
    role: {
        type: DataTypes.ENUM('user', 'admin'),
        defaultValue: 'user'
    },
    status: {
        type: DataTypes.ENUM('active', 'inactive', 'suspended'),
        defaultValue: 'active'
    },
    resetPasswordToken: {
        type: DataTypes.STRING,
        allowNull: true
    },
    resetPasswordExpire: {
        type: DataTypes.DATE,
        allowNull: true
    }
}, {
    hooks: {
        beforeCreate: async (user) => {
            // Hash password
            const salt = await bcrypt.genSalt(10);
            user.password = await bcrypt.hash(user.password, salt);

            // Generate referral code
            if (!user.referral_code) {
                user.referral_code = crypto.randomBytes(3).toString('hex').toUpperCase();
            }
        },
        beforeUpdate: async (user) => {
            if (user.changed('password')) {
                const salt = await bcrypt.genSalt(10);
                user.password = await bcrypt.hash(user.password, salt);
            }
        }
    },
    timestamps: true,
    tableName: 'users'
});

// Instance method to check password
User.prototype.comparePassword = async function (enteredPassword) {
    return await bcrypt.compare(enteredPassword, this.password);
};

// Method to generate password reset token
User.prototype.getResetPasswordToken = function () {
    // Generate token
    const resetToken = crypto.randomBytes(20).toString('hex');

    // Hash and set to resetPasswordToken field
    this.resetPasswordToken = crypto.createHash('sha256').update(resetToken).digest('hex');

    // Set expire (e.g., 30 minutes)
    this.resetPasswordExpire = Date.now() + 30 * 60 * 1000;

    return resetToken;
};

User.prototype.getEmailVerificationOtp = function () {
    const otp = String(crypto.randomInt(0, 1000000)).padStart(6, '0');
    this.resetPasswordToken = crypto.createHash('sha256').update(otp).digest('hex');
    this.resetPasswordExpire = Date.now() + 20 * 60 * 1000;
    return otp;
};

User.prototype.getPasswordResetOtp = function () {
    const otp = String(crypto.randomInt(0, 1000000)).padStart(6, '0');
    this.resetPasswordToken = crypto.createHash('sha256').update(otp).digest('hex');
    this.resetPasswordExpire = Date.now() + 30 * 60 * 1000;
    return otp;
};

module.exports = User;
