const { Sequelize } = require('sequelize');
require('dotenv').config();

const sequelize = new Sequelize(
    process.env.DB_NAME || 'repvio_db',
    process.env.DB_USER || 'repvio_user',
    process.env.DB_PASS || 'Repvio@123!',
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
        
        // Sync models
        // await sequelize.sync({ alter: true }); 
    } catch (error) {
        console.error('❌ Unable to connect to the database:', error.message);
        process.exit(1);
    }
};

module.exports = { sequelize, connectDB };
