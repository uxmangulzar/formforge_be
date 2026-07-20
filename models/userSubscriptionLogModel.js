const { DataTypes } = require('sequelize');
const { sequelize } = require('../database/db');

const UserSubscriptionLog = sequelize.define(
    'UserSubscriptionLog',
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
        action: {
            type: DataTypes.ENUM(
                'created',
                'expiry_updated',
                'deactivated',
                'cancelled',
                'refunded',
                'deleted',
                'reactivated',
                'store_synced'
            ),
            allowNull: false
        },
        performed_by: {
            type: DataTypes.CHAR(36),
            allowNull: true
        },
        note: {
            type: DataTypes.TEXT,
            allowNull: true
        },
        metadata: {
            type: DataTypes.JSON,
            allowNull: true
        }
    },
    {
        timestamps: true,
        updatedAt: false,
        tableName: 'user_subscription_logs'
    }
);

module.exports = UserSubscriptionLog;
