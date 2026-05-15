const { DataTypes } = require('sequelize');
const { sequelize } = require('../database/db');

const UserChallenge = sequelize.define('UserChallenge', {
    id: {
        type: DataTypes.CHAR(36),
        primaryKey: true,
        defaultValue: DataTypes.UUIDV4
    },
    user_id: {
        type: DataTypes.CHAR(36),
        allowNull: false
    },
    challenge_id: {
        type: DataTypes.CHAR(36),
        allowNull: false
    },
    status: {
        type: DataTypes.ENUM('joined', 'in_progress', 'completed', 'failed', 'expired'),
        allowNull: false,
        defaultValue: 'joined'
    },
    total_points_earned: {
        type: DataTypes.INTEGER,
        allowNull: false,
        defaultValue: 0
    },
    joined_at: {
        type: DataTypes.DATE,
        allowNull: false
    },
    completed_at: {
        type: DataTypes.DATE,
        allowNull: true
    }
}, {
    timestamps: true,
    tableName: 'user_challenges'
});

module.exports = UserChallenge;
