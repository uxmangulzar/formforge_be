const express = require('express');
const router = express.Router();
const { protectUser } = require('../middleware/userAuth');
const {
    createWorkout,
    getWorkouts,
    getWorkoutStats,
    getWorkout
} = require('../controllers/workoutController');

router.use(protectUser);

router.post('/', createWorkout);
router.get('/stats', getWorkoutStats);
router.get('/', getWorkouts);
router.get('/:id', getWorkout);

module.exports = router;
