const { DataTypes } = require('sequelize');
const { sequelize } = require('../database/db');

const WorkoutSession = sequelize.define('WorkoutSession', {
    id: {
        type: DataTypes.CHAR(36),
        primaryKey: true,
        defaultValue: DataTypes.UUIDV4
    },
    user_id: {
        type: DataTypes.CHAR(36),
        allowNull: false
    },
    exercise_id: {
        type: DataTypes.CHAR(36),
        allowNull: false
    },
    mode: {
        type: DataTypes.ENUM('train', 'play', 'recover'),
        allowNull: false
    },
    challenge_id: {
        type: DataTypes.CHAR(36),
        allowNull: true
    },
    form_score: {
        type: DataTypes.INTEGER,
        allowNull: true
    },
    reps: {
        type: DataTypes.INTEGER,
        allowNull: false,
        defaultValue: 0
    },
    sets: {
        type: DataTypes.INTEGER,
        allowNull: false,
        defaultValue: 0
    },
    duration_sec: {
        type: DataTypes.INTEGER,
        allowNull: false,
        defaultValue: 0
    },
    calories: {
        type: DataTypes.INTEGER,
        allowNull: true
    },
    xp_earned: {
        type: DataTypes.INTEGER,
        allowNull: false,
        defaultValue: 0
    },
    mistakes: {
        type: DataTypes.JSON,
        allowNull: true
    },
    notes: {
        type: DataTypes.TEXT,
        allowNull: true
    },
    completed_at: {
        type: DataTypes.DATE,
        allowNull: false
    }
}, {
    timestamps: true,
    tableName: 'workout_sessions'
});

module.exports = WorkoutSession;
