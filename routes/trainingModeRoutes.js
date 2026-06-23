const express = require('express');
const router = express.Router();
const { getTrainingModes, getTrainingMode } = require('../controllers/trainingModeController');

router.get('/', getTrainingModes);
router.get('/:idOrSlug', getTrainingMode);

module.exports = router;
