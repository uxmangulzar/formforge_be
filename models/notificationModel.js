const { DataTypes } = require('sequelize');
const { sequelize } = require('../database/db');

const Notification = sequelize.define(
    'Notification',
    {
        id: {
            type: DataTypes.CHAR(36),
            primaryKey: true,
            defaultValue: DataTypes.UUIDV4
        },
        recipient_user_id: {
            type: DataTypes.CHAR(36),
            allowNull: false
        },
        type: {
            type: DataTypes.STRING(64),
            allowNull: false
        },
        title: {
            type: DataTypes.STRING(255),
            allowNull: false
        },
        body: {
            type: DataTypes.TEXT,
            allowNull: true
        },
        metadata: {
            type: DataTypes.JSON,
            allowNull: true
        },
        read_at: {
            type: DataTypes.DATE,
            allowNull: true
        }
    },
    {
        tableName: 'notifications',
        timestamps: true,
        createdAt: 'createdAt',
        updatedAt: 'updatedAt'
    }
);

module.exports = Notification;
