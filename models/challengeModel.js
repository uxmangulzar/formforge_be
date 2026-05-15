const { DataTypes } = require('sequelize');
const { sequelize } = require('../database/db');

const Challenge = sequelize.define('Challenge', {
    id: {
        type: DataTypes.CHAR(36),
        primaryKey: true,
        defaultValue: DataTypes.UUIDV4
    },
    name: {
        type: DataTypes.STRING(255),
        allowNull: false
    },
    description: {
        type: DataTypes.TEXT,
        allowNull: true
    },
    image_urls: {
        type: DataTypes.JSON,
        allowNull: true
    },
    video_urls: {
        type: DataTypes.JSON,
        allowNull: true
    },
    starts_at: {
        type: DataTypes.DATE,
        allowNull: false
    },
    ends_at: {
        type: DataTypes.DATE,
        allowNull: false
    },
    status: {
        type: DataTypes.ENUM('draft', 'published', 'archived'),
        allowNull: false,
        defaultValue: 'draft'
    }
}, {
    timestamps: true,
    tableName: 'challenges'
});

module.exports = Challenge;
