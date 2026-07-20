const { DataTypes } = require('sequelize');
const { sequelize } = require('../database/db');

const Badge = sequelize.define('Badge', {
    id: {
        type: DataTypes.CHAR(36),
        primaryKey: true,
        defaultValue: DataTypes.UUIDV4
    },
    challenge_id: {
        type: DataTypes.CHAR(36),
        allowNull: true
    },
    name: {
        type: DataTypes.STRING(255),
        allowNull: false
    },
    description: {
        type: DataTypes.TEXT,
        allowNull: true
    },
    icon_url: {
        type: DataTypes.STRING(500),
        allowNull: true
    },
    rarity: {
        type: DataTypes.ENUM('common', 'rare', 'epic', 'legendary'),
        allowNull: false,
        defaultValue: 'common'
    },
    is_active: {
        type: DataTypes.BOOLEAN,
        allowNull: false,
        defaultValue: true
    }
}, {
    timestamps: true,
    tableName: 'badges'
});

module.exports = Badge;
