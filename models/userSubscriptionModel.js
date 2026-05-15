const { DataTypes } = require('sequelize');
const { sequelize } = require('../database/db');

const UserSubscription = sequelize.define(
    'UserSubscription',
    {
        id: {
            type: DataTypes.CHAR(36),
            primaryKey: true,
            defaultValue: DataTypes.UUIDV4
        },
        user_id: {
            type: DataTypes.CHAR(36),
            allowNull: false
        },
        subscription_plan_id: {
            type: DataTypes.CHAR(36),
            allowNull: false
        },
        status: {
            type: DataTypes.ENUM('trialing', 'active', 'expired', 'cancelled', 'paused'),
            allowNull: false,
            defaultValue: 'active'
        },
        platform: {
            type: DataTypes.ENUM('google_play', 'app_store', 'manual', 'admin'),
            allowNull: false,
            defaultValue: 'manual'
        },
        store_purchase_token: {
            type: DataTypes.STRING(512),
            allowNull: true
        },
        started_at: {
            type: DataTypes.DATE,
            allowNull: false,
            defaultValue: DataTypes.NOW
        },
        expires_at: {
            type: DataTypes.DATE,
            allowNull: true
        },
        cancelled_at: {
            type: DataTypes.DATE,
            allowNull: true
        },
        refunded_at: {
            type: DataTypes.DATE,
            allowNull: true
        },
        deactivated_at: {
            type: DataTypes.DATE,
            allowNull: true
        },
        auto_renew: {
            type: DataTypes.BOOLEAN,
            allowNull: false,
            defaultValue: true
        }
    },
    {
        timestamps: true,
        tableName: 'user_subscriptions'
    }
);

module.exports = UserSubscription;
