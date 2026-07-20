const fs = require('fs');
const path = require('path');
const mysql = require('mysql2/promise');
require('dotenv').config();

const runMigrations = async () => {
    let adminConn;
    let dbConn;
    try {
        const dbName = process.env.DB_NAME || 'formforge_db';
        const host = process.env.DB_HOST || 'localhost';
        const user = process.env.DB_USER || 'root';
        const password = process.env.DB_PASS || '';

        // const dbName = process.env.DB_NAME || 'repvio_db';
        // const host = process.env.DB_HOST || 'localhost';
        // const user = process.env.DB_USER || 'repvio_user';
        // const password = process.env.DB_PASS || 'Repvio@123!';

        console.log('🔌 Connecting to MySQL Server...');
        adminConn = await mysql.createConnection({
            host,
            user,
            password
        });

        console.log(`🛠️ Ensuring database "${dbName}" exists...`);
        await adminConn.query(`CREATE DATABASE IF NOT EXISTS \`${dbName}\`;`);
        await adminConn.end();
        adminConn = null;

        dbConn = await mysql.createConnection({
            host,
            user,
            password,
            database: dbName,
            multipleStatements: true
        });
        console.log(`📡 Using database "${dbName}" (multipleStatements: on)`);

        const migrationFile = process.argv[2];
        const migrationsDir = path.join(__dirname, '../migrations');

        const executeFile = async (fileName) => {
            console.log(`⏳ Executing: ${fileName}...`);
            const filePath = path.join(migrationsDir, fileName);
            let sql = fs.readFileSync(filePath, 'utf8');

            sql = sql.replace(/USE\s+[\w`]+;/gi, '').trim();
            if (!sql) {
                console.log(`⏭️ Skipped (empty): ${fileName}`);
                return;
            }

            await dbConn.query(sql);
            console.log(`✅ Finished: ${fileName}`);
        };

        if (migrationFile) {
            await executeFile(migrationFile);
        } else {
            const files = fs
                .readdirSync(migrationsDir)
                .filter((file) => file.endsWith('.sql'))
                .sort();

            for (const file of files) {
                await executeFile(file);
            }
        }

        await dbConn.end();
        dbConn = null;

        console.log('🚀 All migrations completed successfully!');
        process.exit(0);
    } catch (error) {
        console.error('❌ Migration failed:', error.message);
        if (adminConn) await adminConn.end().catch(() => {});
        if (dbConn) await dbConn.end().catch(() => {});
        process.exit(1);
    }
};

runMigrations();
