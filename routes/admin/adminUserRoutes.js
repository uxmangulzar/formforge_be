const express = require('express');
const router = express.Router();
const { getAllUsers, getUserById, updateUserStatus, deleteUser, createUser } = require('../../controllers/admin/adminUserController');
const { protectAdmin } = require('../../middleware/adminAuth');

// All routes here are protected by Admin Auth
router.use(protectAdmin);

router.get('/', getAllUsers);
router.get('/:id', getUserById);
router.post('/', createUser);
router.patch('/:id/status', updateUserStatus);
router.delete('/:id', deleteUser);

module.exports = router;
