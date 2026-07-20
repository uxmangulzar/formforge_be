const { DataTypes } = require('sequelize');
const { sequelize } = require('../database/db');

const Exercise = sequelize.define(
    'Exercise',
    {
        id: {
            type: DataTypes.CHAR(36),
            primaryKey: true,
            defaultValue: DataTypes.UUIDV4
        },
        name: {
            type: DataTypes.STRING,
            allowNull: false
        },
        type: {
            type: DataTypes.ENUM('train', 'play', 'recover'),
            allowNull: false
        },
        category_id: {
            type: DataTypes.CHAR(36),
            allowNull: false
        },
        category: {
            type: DataTypes.VIRTUAL,
            get() {
                const c = this.exerciseCategory;
                if (c && typeof c.get === 'function') return c.get('slug');
                if (c && c.slug) return c.slug;
                return null;
            }
        },
        description: {
            type: DataTypes.TEXT,
            allowNull: true
        },
        demo_url: {
            type: DataTypes.STRING,
            allowNull: true
        },
        gif_url: {
            type: DataTypes.STRING(512),
            allowNull: true
        },
        data_url: {
            type: DataTypes.STRING,
            allowNull: true
        },
        difficulty: {
            type: DataTypes.ENUM('beginner', 'intermediate', 'advanced'),
            defaultValue: 'beginner'
        },
        target_muscles: {
            type: DataTypes.JSON,
            allowNull: true
        },
        logic_config: {
            type: DataTypes.JSON,
            allowNull: true
        },
        rep_counting_logic: {
            type: DataTypes.JSON,
            allowNull: true
        },
        custom_fields: {
            type: DataTypes.JSON,
            allowNull: true
        },
        is_active: {
            type: DataTypes.BOOLEAN,
            defaultValue: true
        },
        is_locked: {
            type: DataTypes.BOOLEAN,
            allowNull: false,
            defaultValue: false
        }
    },
    {
        timestamps: true,
        tableName: 'exercises'
    }
);

module.exports = Exercise;
