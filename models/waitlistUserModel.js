const { DataTypes } = require('sequelize');
const { sequelize } = require('../database/db');
const crypto = require('crypto');

const WaitlistUser = sequelize.define('WaitlistUser', {
    id: {
        type: DataTypes.CHAR(36),
        defaultValue: DataTypes.UUIDV4,
        primaryKey: true
    },
    email: {
        type: DataTypes.STRING,
        allowNull: false,
        unique: true,
        validate: {
            isEmail: true
        }
    },
    device: {
        type: DataTypes.STRING,
        allowNull: true // iPhone, Android, etc.
    },
    interest: {
        type: DataTypes.STRING,
        allowNull: true // Fitness gaming, etc.
    },
    referralCode: {
        type: DataTypes.STRING,
        unique: true
    },
    referredBy: {
        type: DataTypes.STRING,
        allowNull: true
    },
    referralCount: {
        type: DataTypes.INTEGER,
        defaultValue: 0
    },
    waitlistPosition: {
        type: DataTypes.INTEGER,
        allowNull: true
    }
}, {
    hooks: {
        beforeCreate: (user) => {
            // Generate a random 6-character referral code before saving
            if (!user.referralCode) {
                user.referralCode = crypto.randomBytes(3).toString('hex').toUpperCase();
            }
        }
    },
    timestamps: true,
    tableName: 'waitlistUsers'
});

module.exports = WaitlistUser;
