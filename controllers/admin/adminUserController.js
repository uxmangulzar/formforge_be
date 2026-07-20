const User = require('../../models/userModel');
const Profile = require('../../models/profileModel');
const { Op } = require('sequelize');

// @desc    Get all users
// @route   GET /api/admin/users
// @access  Private/Admin
const getAllUsers = async (req, res, next) => {
    try {
        const users = await User.findAll({
            where: {
                role: {
                    [Op.ne]: 'admin'
                }
            },
            attributes: { exclude: ['password'] },
            include: [{
                model: Profile,
                as: 'profile',
                attributes: ['full_name', 'fitness_level', 'level', 'total_xp']
            }],
            order: [['createdAt', 'DESC']]
        });
        res.status(200).json({ success: true, data: users });
    } catch (error) {
        next(error);
    }
};

// @desc    Get single user with profile
// @route   GET /api/admin/users/:id
// @access  Private/Admin
const getUserById = async (req, res, next) => {
    try {
        const user = await User.findByPk(req.params.id, {
            attributes: { exclude: ['password'] },
            include: [{
                model: Profile,
                as: 'profile'
            }]
        });

        if (!user) {
            res.status(404);
            throw new Error('User not found');
        }

        res.status(200).json({ success: true, data: user });
    } catch (error) {
        next(error);
    }
};

// @desc    Update user status
// @route   PATCH /api/admin/users/:id/status
// @access  Private/Admin
const updateUserStatus = async (req, res, next) => {
    try {
        const { status } = req.body;
        const user = await User.findByPk(req.params.id);

        if (!user) {
            return res.status(404).json({ success: false, message: 'User not found' });
        }

        user.status = status;
        await user.save();

        res.status(200).json({ success: true, message: `User status updated to ${status}` });
    } catch (error) {
        next(error);
    }
};

// @desc    Create new user
// @route   POST /api/admin/users
// @access  Private/Admin
const createUser = async (req, res, next) => {
    try {
        const { email, password, full_name, fitness_level, age, role } = req.body;

        // Check if user exists
        const userExists = await User.findOne({ where: { email } });
        if (userExists) {
            return res.status(400).json({ success: false, message: 'User already exists' });
        }

        // Create user
        const user = await User.create({
            email,
            password,
            role: role || 'user',
            is_verified: true,
            is_profile_completed: true
        });

        // Create profile
        await Profile.create({
            user_id: user.id,
            full_name,
            fitness_level: fitness_level || 'beginner',
            age: age || null
        });

        res.status(201).json({ 
            success: true, 
            message: 'User and Profile created successfully',
            data: { id: user.id, email: user.email }
        });
    } catch (error) {
        next(error);
    }
};

// @desc    Delete user
// @route   DELETE /api/admin/users/:id
// @access  Private/Admin
const deleteUser = async (req, res, next) => {
    try {
        const user = await User.findByPk(req.params.id);

        if (!user) {
            return res.status(404).json({ success: false, message: 'User not found' });
        }

        await user.destroy();
        res.status(200).json({ success: true, message: 'User deleted successfully' });
    } catch (error) {
        next(error);
    }
};

module.exports = {
    getAllUsers,
    getUserById,
    updateUserStatus,
    deleteUser,
    createUser
};
