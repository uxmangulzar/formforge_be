const { DataTypes } = require('sequelize');
const { sequelize } = require('../database/db');

const AdminNotificationSetting = sequelize.define(
    'AdminNotificationSetting',
    {
        user_id: {
            type: DataTypes.CHAR(36),
            primaryKey: true
        },
        in_app_enabled: {
            type: DataTypes.BOOLEAN,
            allowNull: false,
            defaultValue: true
        },
        email_enabled: {
            type: DataTypes.BOOLEAN,
            allowNull: false,
            defaultValue: false
        },
        allowed_types: {
            type: DataTypes.JSON,
            allowNull: true
        }
    },
    {
        tableName: 'admin_notification_settings',
        timestamps: true,
        createdAt: 'createdAt',
        updatedAt: 'updatedAt'
    }
);

module.exports = AdminNotificationSetting;
