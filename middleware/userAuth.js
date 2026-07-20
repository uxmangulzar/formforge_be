const jwt = require('jsonwebtoken');
const User = require('../models/userModel');

const protectUser = async (req, res, next) => {
    let token;

    if (req.headers.authorization && req.headers.authorization.startsWith('Bearer')) {
        try {
            token = req.headers.authorization.split(' ')[1];
            const decoded = jwt.verify(token, process.env.JWT_SECRET);
            req.user = await User.findByPk(decoded.id);

            if (!req.user || req.user.role !== 'user') {
                res.status(403);
                throw new Error('Not authorized as an app user');
            }
            if (req.user.status !== 'active') {
                res.status(403);
                throw new Error('Account is not active');
            }

            return next();
        } catch (error) {
            console.error(error);
            res.status(401);
            return next(new Error('Not authorized, token failed'));
        }
    }

    res.status(401);
    return next(new Error('Not authorized, no token'));
};

module.exports = { protectUser };
