const { DataTypes } = require('sequelize');
const { sequelize } = require('../database/db');

const ExerciseCategory = sequelize.define(
    'ExerciseCategory',
    {
        id: {
            type: DataTypes.CHAR(36),
            primaryKey: true,
            defaultValue: DataTypes.UUIDV4
        },
        slug: {
            type: DataTypes.STRING(64),
            allowNull: false,
            unique: true
        },
        display_name: {
            type: DataTypes.STRING(120),
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
        },
        is_locked: {
            type: DataTypes.BOOLEAN,
            allowNull: false,
            defaultValue: false
        }
    },
    {
        tableName: 'exercise_categories',
        timestamps: true,
        createdAt: 'createdAt',
        updatedAt: 'updatedAt'
    }
);

module.exports = ExerciseCategory;
