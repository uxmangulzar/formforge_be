const { DataTypes } = require('sequelize');
const { sequelize } = require('../database/db');

const UserChallengeExerciseProgress = sequelize.define('UserChallengeExerciseProgress', {
    id: {
        type: DataTypes.CHAR(36),
        primaryKey: true,
        defaultValue: DataTypes.UUIDV4
    },
    user_challenge_id: {
        type: DataTypes.CHAR(36),
        allowNull: false
    },
    challenge_stage_exercise_id: {
        type: DataTypes.CHAR(36),
        allowNull: false
    },
    sets_completed: {
        type: DataTypes.INTEGER,
        allowNull: false,
        defaultValue: 0
    },
    reps_logged: {
        type: DataTypes.INTEGER,
        allowNull: false,
        defaultValue: 0
    },
    form_score: {
        type: DataTypes.INTEGER,
        allowNull: true
    },
    mistakes: {
        type: DataTypes.JSON,
        allowNull: true
    },
    status: {
        type: DataTypes.ENUM('not_started', 'in_progress', 'completed'),
        allowNull: false,
        defaultValue: 'not_started'
    },
    points_awarded: {
        type: DataTypes.INTEGER,
        allowNull: false,
        defaultValue: 0
    },
    completed_at: {
        type: DataTypes.DATE,
        allowNull: true
    }
}, {
    timestamps: true,
    tableName: 'user_challenge_exercise_progress'
});

module.exports = UserChallengeExerciseProgress;
