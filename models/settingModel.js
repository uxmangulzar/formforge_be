const { DataTypes } = require('sequelize');
const { sequelize } = require('../database/db');

const Setting = sequelize.define('Setting', {
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
    }
}, {
    timestamps: true
});

module.exports = Setting;
