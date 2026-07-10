const { Sequelize } = require('sequelize');
require('dotenv').config();

const sequelize = new Sequelize(
    process.env.DB_NAME || 'formforge_db',
    process.env.DB_USER || 'root',
    process.env.DB_PASS || '',
    {
        host: process.env.DB_HOST || 'localhost',
        dialect: 'mysql',
        logging: false, // Set to console.log to see SQL queries
    }
);

const connectDB = async () => {
    try {
        await sequelize.authenticate();
        console.log('📡 MySQL Database Connected via Sequelize...');
    } catch (error) {
        console.error('❌ Database authentication failed:', error.message);
        process.exit(1);
    }
};

module.exports = { sequelize, connectDB };
