const { DataTypes } = require('sequelize');
const { sequelize } = require('../database/db');

const ChallengeStageExercise = sequelize.define('ChallengeStageExercise', {
    id: {
        type: DataTypes.CHAR(36),
        primaryKey: true,
        defaultValue: DataTypes.UUIDV4
    },
    challenge_stage_id: {
        type: DataTypes.CHAR(36),
        allowNull: false
    },
    exercise_id: {
        type: DataTypes.CHAR(36),
        allowNull: false
    },
    type: {
        type: DataTypes.STRING(50),
        allowNull: false,
        defaultValue: 'all'
    },
    sequence_order: {
        type: DataTypes.INTEGER,
        allowNull: false
    },
    target_sets: {
        type: DataTypes.INTEGER,
        allowNull: false,
        defaultValue: 1
    },
    target_reps: {
        type: DataTypes.INTEGER,
        allowNull: false,
        defaultValue: 1
    },
    points_on_complete: {
        type: DataTypes.INTEGER,
        allowNull: false,
        defaultValue: 0
    },
    optional: {
        type: DataTypes.BOOLEAN,
        allowNull: false,
        defaultValue: false
    },
    notes: {
        type: DataTypes.STRING(500),
        allowNull: true
    }
}, {
    timestamps: true,
    tableName: 'challenge_stage_exercises'
});

module.exports = ChallengeStageExercise;
