const { DataTypes } = require('sequelize');
const { sequelize } = require('../database/db');

const UserChallengeStageProgress = sequelize.define('UserChallengeStageProgress', {
    id: {
        type: DataTypes.CHAR(36),
        primaryKey: true,
        defaultValue: DataTypes.UUIDV4
    },
    user_challenge_id: {
        type: DataTypes.CHAR(36),
        allowNull: false
    },
    challenge_stage_id: {
        type: DataTypes.CHAR(36),
        allowNull: false
    },
    status: {
        type: DataTypes.ENUM('locked', 'active', 'completed'),
        allowNull: false,
        defaultValue: 'locked'
    },
    completed_at: {
        type: DataTypes.DATE,
        allowNull: true
    }
}, {
    timestamps: true,
    tableName: 'user_challenge_stage_progress'
});

module.exports = UserChallengeStageProgress;
