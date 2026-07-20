const { DataTypes } = require('sequelize');
const { sequelize } = require('../database/db');

const UserBadge = sequelize.define('UserBadge', {
    id: {
        type: DataTypes.CHAR(36),
        primaryKey: true,
        defaultValue: DataTypes.UUIDV4
    },
    user_id: {
        type: DataTypes.CHAR(36),
        allowNull: false
    },
    badge_id: {
        type: DataTypes.CHAR(36),
        allowNull: false
    },
    earned_at: {
        type: DataTypes.DATE,
        allowNull: false
    },
    context: {
        type: DataTypes.JSON,
        allowNull: true
    }
}, {
    timestamps: true,
    tableName: 'user_badges'
});

module.exports = UserBadge;
