const express = require('express');
const router = express.Router();
const { protectUser } = require('../middleware/userAuth');
const {
    createWorkout,
    getWorkouts,
    getWorkoutStats,
    getWorkout,
    getWorkoutDashboard
} = require('../controllers/workoutController');

router.use(protectUser);

router.get('/dashboard', getWorkoutDashboard);
router.post('/', createWorkout);
router.get('/stats', getWorkoutStats);
router.get('/', getWorkouts);
router.get('/:id', getWorkout);


module.exports = router;
