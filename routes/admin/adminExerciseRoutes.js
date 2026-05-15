const express = require('express');
const multer = require('multer');
const router = express.Router();
const { protectAdmin } = require('../../middleware/adminAuth');
const {
    exportAdminExercises,
    downloadAdminExerciseTemplate,
    importAdminExercises
} = require('../../controllers/admin/adminExerciseController');

const upload = multer({
    storage: multer.memoryStorage(),
    limits: { fileSize: 15 * 1024 * 1024 },
    fileFilter: (req, file, cb) => {
        const name = (file.originalname || '').toLowerCase();
        const mime = (file.mimetype || '').toLowerCase();
        const ok =
            name.endsWith('.csv') ||
            name.endsWith('.xlsx') ||
            name.endsWith('.xls') ||
            mime.includes('csv') ||
            mime.includes('spreadsheet') ||
            mime.includes('excel');
        if (ok) cb(null, true);
        else cb(new Error('Only CSV or Excel (.xlsx) files are allowed'));
    }
});

router.use(protectAdmin);

router.get('/export', exportAdminExercises);
router.get('/import-template', downloadAdminExerciseTemplate);
router.post('/import', (req, res, next) => {
    upload.single('file')(req, res, (err) => {
        if (err) {
            return res.status(400).json({ success: false, message: err.message || 'Upload failed' });
        }
        importAdminExercises(req, res, next);
    });
});

module.exports = router;
