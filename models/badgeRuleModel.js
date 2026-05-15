const { DataTypes } = require('sequelize');
const { sequelize } = require('../database/db');

const BadgeRule = sequelize.define('BadgeRule', {
    id: {
        type: DataTypes.CHAR(36),
        primaryKey: true,
        defaultValue: DataTypes.UUIDV4
    },
    badge_id: {
        type: DataTypes.CHAR(36),
        allowNull: false
    },
    challenge_id: {
        type: DataTypes.CHAR(36),
        allowNull: true
    },
    trigger_type: {
        type: DataTypes.ENUM(
            'points_threshold',
            'challenge_complete',
            'challenge_all_stages',
            'custom'
        ),
        allowNull: false
    },
    trigger_config: {
        type: DataTypes.JSON,
        allowNull: true
    },
    priority: {
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
    tableName: 'badge_rules'
});

module.exports = BadgeRule;
