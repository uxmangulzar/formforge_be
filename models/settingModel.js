const { DataTypes } = require('sequelize');
const { sequelize } = require('../database/db');

const Setting = sequelize.define('Setting', {
    id: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        autoIncrement: true
    },
    setting_key: {
        type: DataTypes.STRING,
        allowNull: false,
        unique: true
    },
    setting_value: {
        type: DataTypes.TEXT,
        allowNull: true
    },
    description: {
        type: DataTypes.STRING,
        allowNull: true
    },
    is_active: {
        type: DataTypes.BOOLEAN,
        allowNull: false,
        defaultValue: true
    }
}, {
    timestamps: true,
    tableName: 'Settings'
});

module.exports = Setting;
