const { DataTypes } = require('sequelize');
const { sequelize } = require('../database/db');

const SubscriptionPlan = sequelize.define(
    'SubscriptionPlan',
    {
        id: {
            type: DataTypes.CHAR(36),
            primaryKey: true,
            defaultValue: DataTypes.UUIDV4
        },
        name: {
            type: DataTypes.STRING(120),
            allowNull: false
        },
        description: {
            type: DataTypes.TEXT,
            allowNull: true
        },
        status: {
            type: DataTypes.ENUM('draft', 'active', 'inactive', 'archived'),
            allowNull: false,
            defaultValue: 'draft'
        },
        free_trials: {
            type: DataTypes.INTEGER,
            allowNull: false,
            defaultValue: 0
        },
        price: {
            type: DataTypes.DECIMAL(10, 2),
            allowNull: false,
            defaultValue: 0
        },
        currency: {
            type: DataTypes.CHAR(3),
            allowNull: false,
            defaultValue: 'USD'
        },
        features: {
            type: DataTypes.JSON,
            allowNull: true
        },
        play_store_sub_id: {
            type: DataTypes.STRING(255),
            allowNull: true
        },
        app_store_sub_id: {
            type: DataTypes.STRING(255),
            allowNull: true
        }
    },
    {
        timestamps: true,
        tableName: 'subscription_plans'
    }
);

module.exports = SubscriptionPlan;
