const { DataTypes } = require('sequelize');
const { sequelize } = require('../database/db');

const UserSubscriptionStoreSync = sequelize.define(
    'UserSubscriptionStoreSync',
    {
        id: {
            type: DataTypes.CHAR(36),
            primaryKey: true,
            defaultValue: DataTypes.UUIDV4
        },
        user_subscription_id: {
            type: DataTypes.CHAR(36),
            allowNull: false
        },
        user_id: {
            type: DataTypes.CHAR(36),
            allowNull: false
        },
        platform: {
            type: DataTypes.ENUM('google_play', 'app_store'),
            allowNull: false
        },
        sync_type: {
            type: DataTypes.ENUM('pull', 'cancel', 'refund'),
            allowNull: false,
            defaultValue: 'pull'
        },
        status: {
            type: DataTypes.ENUM('success', 'no_change', 'failed', 'manual_required'),
            allowNull: false
        },
        message: {
            type: DataTypes.STRING(500),
            allowNull: true
        },
        store_status: {
            type: DataTypes.STRING(64),
            allowNull: true
        },
        store_expires_at: {
            type: DataTypes.DATE,
            allowNull: true
        },
        store_auto_renew: {
            type: DataTypes.BOOLEAN,
            allowNull: true
        },
        store_product_id: {
            type: DataTypes.STRING(255),
            allowNull: true
        },
        user_updated: {
            type: DataTypes.BOOLEAN,
            allowNull: false,
            defaultValue: false
        },
        previous_data: {
            type: DataTypes.JSON,
            allowNull: true
        },
        store_snapshot: {
            type: DataTypes.JSON,
            allowNull: true
        },
        applied_updates: {
            type: DataTypes.JSON,
            allowNull: true
        },
        error_detail: {
            type: DataTypes.TEXT,
            allowNull: true
        },
        performed_by: {
            type: DataTypes.CHAR(36),
            allowNull: true
        }
    },
    {
        tableName: 'user_subscription_store_syncs',
        timestamps: true,
        updatedAt: false
    }
);

module.exports = UserSubscriptionStoreSync;
