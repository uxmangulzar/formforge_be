const authService = require('../../services/authService');

const adminLogin = async (req, res, next) => {
    try {
        const { email, password } = req.body;

        if (!email || !password) {
            res.status(400);
            throw new Error('Please provide email and password');
        }

        const user = await authService.loginUser({ email, password });

        // Security Check: Only allow if role is admin
        if (user.role !== 'admin') {
            res.status(403);
            throw new Error('Access Denied: You do not have admin privileges.');
        }

        res.status(200).json({
            success: true,
            message: 'Admin login successful',
            data: user
        });
    } catch (error) {
        next(error);
    }
};

module.exports = {
    adminLogin
};
