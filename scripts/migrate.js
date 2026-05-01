const fs = require('fs');
const path = require('path');
const mysql = require('mysql2/promise');
require('dotenv').config();
const { sequelize, connectDB } = require('../database/db');

const runMigrations = async () => {
    let connection;
    try {
        // 1. First connect to MySQL without specifying a database to ensure it exists
        console.log('🔌 Connecting to MySQL Server...');
        connection = await mysql.createConnection({
            host: process.env.DB_HOST || 'localhost',
            user: process.env.DB_USER || 'root',
            password: process.env.DB_PASS || '',
        });

        const dbName = process.env.DB_NAME || 'formforge_db';
        console.log(`🛠️ Ensuring database "${dbName}" exists...`);
        await connection.query(`CREATE DATABASE IF NOT EXISTS \`${dbName}\`;`);
        await connection.end();

        // 2. Now use Sequelize to run migrations
        await connectDB();
        
        const migrationFile = process.argv[2]; 
        const migrationsDir = path.join(__dirname, '../migrations');

        const executeFile = async (fileName) => {
            console.log(`⏳ Executing: ${fileName}...`);
            const filePath = path.join(migrationsDir, fileName);
            let sql = fs.readFileSync(filePath, 'utf8');
            
            // Remove 'USE database_name' if it exists to avoid conflicts
            sql = sql.replace(/USE\s+[\w`]+;/gi, '');

            const queries = sql.split(';').filter(query => query.trim() !== '');
            
            for (let query of queries) {
                await sequelize.query(query);
            }
            console.log(`✅ Finished: ${fileName}`);
        };

        if (migrationFile) {
            await executeFile(migrationFile);
        } else {
            const files = fs.readdirSync(migrationsDir)
                .filter(file => file.endsWith('.sql'))
                .sort(); // Sort to ensure 00_ files run first

            for (const file of files) {
                await executeFile(file);
            }
        }

        console.log('🚀 All migrations completed successfully!');
        process.exit(0);
    } catch (error) {
        console.error('❌ Migration failed:', error.message);
        if (connection) await connection.end();
        process.exit(1);
    }
};

runMigrations();
