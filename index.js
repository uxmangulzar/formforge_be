const express = require('express');
const cors = require('cors');
require('dotenv').config();
const { connectDB, sequelize } = require('./database/db');
const { errorHandler } = require('./middleware/errorMiddleware');
const User = require('./models/userModel');
const Setting = require('./models/settingModel');

// Routes
const userRoutes = require('./routes/userRoutes');

const app = express();
const PORT = process.env.PORT || 5000;

// Middleware
app.use(cors());
app.use(express.json());

// Routes Usage
app.use('/api/users', userRoutes);

// Base Route
app.get('/', (req, res) => {
    res.status(200).json({
        success: true,
        message: 'FormForge AI Backend is Live!',
        version: '1.0.0'
    });
});

// Health Check Route
app.get('/health', (req, res) => {
    res.status(200).json({ status: 'OK' });
});

// Error Middleware
app.use(errorHandler);

const startServer = async () => {
    try {
        await connectDB();
        
        // Sync database (Wait for tables to be created)
        await sequelize.sync();
        
        app.listen(PORT, () => {
            console.log(`
🚀 Server is screaming at http://localhost:${PORT}
🛠️  Mode: Development
            `);
        });
    } catch (error) {
        console.error('Failed to start server:', error);
    }
};

startServer();
