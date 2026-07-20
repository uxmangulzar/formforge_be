const { DataTypes } = require('sequelize');
const { sequelize } = require('../database/db');

const Profile = sequelize.define('Profile', {
    id: {
        type: DataTypes.CHAR(36),
        primaryKey: true,
        defaultValue: DataTypes.UUIDV4
    },
    user_id: {
        type: DataTypes.CHAR(36),
        allowNull: false
    },
    full_name: {
        type: DataTypes.STRING,
        allowNull: true
    },
    avatar_url: {
        type: DataTypes.STRING,
        allowNull: true
    },
    age: {
        type: DataTypes.INTEGER,
        allowNull: true
    },
    fitness_level: {
        type: DataTypes.ENUM('beginner', 'intermediate', 'advanced'),
        defaultValue: 'beginner'
    },
    goal: {
        type: DataTypes.TEXT,
        allowNull: true
    },
    injury_history: {
        type: DataTypes.TEXT,
        allowNull: true
    },
    total_xp: {
        type: DataTypes.INTEGER,
        defaultValue: 0
    },
    level: {
        type: DataTypes.INTEGER,
        defaultValue: 1
    },
    current_streak: {
        type: DataTypes.INTEGER,
        defaultValue: 0
    },
    longest_streak: {
        type: DataTypes.INTEGER,
        defaultValue: 0
    },
    last_streak_date: {
        type: DataTypes.DATEONLY,
        allowNull: true
    },
    preferred_language: {
        type: DataTypes.STRING(10),
        defaultValue: 'en'
    }
}, {
    timestamps: true,
    tableName: 'profiles'
});

module.exports = Profile;
