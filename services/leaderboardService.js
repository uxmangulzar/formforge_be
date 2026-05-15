const { QueryTypes } = require('sequelize');
const { sequelize } = require('../database/db');

/**
 * Registered app users (role user) ranked by sum of challenge points.
 * Users with no challenge rows appear with total_points = 0.
 */
const getAppUsersLeaderboard = async (limit = 100) => {
    const lim = Math.min(Math.max(parseInt(limit, 10) || 100, 1), 500);

    const rows = await sequelize.query(
        `SELECT u.id AS user_id,
                u.email AS email,
                u.status AS status,
                CAST(COALESCE(SUM(uc.total_points_earned), 0) AS SIGNED) AS total_points
         FROM users u
         LEFT JOIN user_challenges uc ON uc.user_id = u.id
         WHERE u.role = 'user'
         GROUP BY u.id, u.email, u.status
         ORDER BY total_points DESC, u.email ASC
         LIMIT :limit`,
        { replacements: { limit: lim }, type: QueryTypes.SELECT }
    );

    return rows.map((row, index) => ({
        rank: index + 1,
        user_id: row.user_id,
        email: row.email,
        status: row.status,
        total_points: Number(row.total_points) || 0
    }));
};

module.exports = {
    getAppUsersLeaderboard
};
