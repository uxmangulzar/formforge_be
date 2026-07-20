const { DataTypes } = require('sequelize');
const { sequelize } = require('../database/db');

const TrainingMode = sequelize.define('TrainingMode', {
    id: {
        type: DataTypes.CHAR(36),
        primaryKey: true,
        defaultValue: DataTypes.UUIDV4
    },
    slug: {
        type: DataTypes.STRING(50),
        allowNull: false,
        unique: true
    },
    display_name: {
        type: DataTypes.STRING(100),
        allowNull: false
    },
    description: {
        type: DataTypes.STRING(500),
        allowNull: true
    },
    sort_order: {
        type: DataTypes.INTEGER,
        allowNull: false,
        defaultValue: 0
    },
    is_active: {
        type: DataTypes.BOOLEAN,
        allowNull: false,
        defaultValue: true
    }
}, {
    timestamps: true,
    tableName: 'training_modes'
});

module.exports = TrainingMode;
