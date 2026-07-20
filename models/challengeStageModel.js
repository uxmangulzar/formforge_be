const { DataTypes } = require('sequelize');
const { sequelize } = require('../database/db');

const ChallengeStage = sequelize.define('ChallengeStage', {
    id: {
        type: DataTypes.CHAR(36),
        primaryKey: true,
        defaultValue: DataTypes.UUIDV4
    },
    challenge_id: {
        type: DataTypes.CHAR(36),
        allowNull: false
    },
    stage_order: {
        type: DataTypes.INTEGER,
        allowNull: false
    },
    title: {
        type: DataTypes.STRING(255),
        allowNull: false
    },
    description: {
        type: DataTypes.TEXT,
        allowNull: true
    },
    points_bonus: {
        type: DataTypes.INTEGER,
        allowNull: false,
        defaultValue: 0
    }
}, {
    timestamps: true,
    tableName: 'challenge_stages'
});

module.exports = ChallengeStage;
