const jwt = require('jsonwebtoken');
const User = require('../models/userModel');

const protectAdmin = async (req, res, next) => {
    let token;

    if (req.headers.authorization && req.headers.authorization.startsWith('Bearer')) {
        try {
            // Get token from header
            token = req.headers.authorization.split(' ')[1];

            // Verify token
            const decoded = jwt.verify(token, process.env.JWT_SECRET);

            // Get user from token
            req.user = await User.findByPk(decoded.id);

            if (!req.user || req.user.role !== 'admin') {
                res.status(403);
                throw new Error('Not authorized as an admin');
            }

            return next();
        } catch (error) {
            console.error(error);
            res.status(401);
            return next(new Error('Not authorized, token failed'));
        }
    }

    if (!token) {
        res.status(401);
        return next(new Error('Not authorized, no token'));
    }
};

module.exports = { protectAdmin };
