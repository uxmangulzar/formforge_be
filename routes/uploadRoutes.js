const express = require('express');
const router = express.Router();
const multer = require('multer');
const path = require('path');
const { protectAdmin } = require('../middleware/adminAuth');

const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, 'uploads/');
    },
    filename: (req, file, cb) => {
        const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1e9);
        cb(null, file.fieldname + '-' + uniqueSuffix + path.extname(file.originalname));
    }
});

const upload = multer({ storage });

const gifStorage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, 'uploads/');
    },
    filename: (req, file, cb) => {
        const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1e9);
        cb(null, 'gif-' + uniqueSuffix + '.gif');
    }
});

const gifFileFilter = (req, file, cb) => {
    const mime = (file.mimetype || '').toLowerCase();
    const orig = (file.originalname || '').toLowerCase();
    if (mime === 'image/gif' || orig.endsWith('.gif')) {
        cb(null, true);
    } else {
        cb(new Error('Only GIF files are allowed'));
    }
};

const uploadGif = multer({
    storage: gifStorage,
    fileFilter: gifFileFilter,
    limits: { fileSize: 15 * 1024 * 1024 }
});

const challengeImageFilter = (req, file, cb) => {
    const mime = (file.mimetype || '').toLowerCase();
    const orig = (file.originalname || '').toLowerCase();
    const okMime = /^image\/(jpeg|jpg|pjpeg|png|webp|gif)$/i.test(mime);
    const okExt = /\.(jpe?g|png|webp|gif)$/i.test(orig);
    if (okMime || okExt) cb(null, true);
    else cb(new Error('Only image files are allowed (JPEG, PNG, WebP, GIF)'));
};

const challengeVideoFilter = (req, file, cb) => {
    const mime = (file.mimetype || '').toLowerCase();
    const orig = (file.originalname || '').toLowerCase();
    const okMime = /^video\/(mp4|webm|quicktime|x-msvideo)$/i.test(mime);
    const okExt = /\.(mp4|webm|mov|avi)$/i.test(orig);
    if (okMime || okExt) cb(null, true);
    else cb(new Error('Only video files are allowed (MP4, WebM, MOV, AVI)'));
};

const challengeImagesUpload = multer({
    storage,
    fileFilter: challengeImageFilter,
    limits: { fileSize: 12 * 1024 * 1024 }
});

const challengeVideosUpload = multer({
    storage,
    fileFilter: challengeVideoFilter,
    limits: { fileSize: 100 * 1024 * 1024 }
});

const runArrayUpload = (mw) => (req, res) => {
    mw(req, res, (err) => {
        if (err) {
            return res.status(400).json({
                success: false,
                message: err.message || 'Upload failed'
            });
        }
        if (!req.files || !req.files.length) {
            return res.status(400).json({ success: false, message: 'No files uploaded' });
        }
        const urls = req.files.map((f) => `/uploads/${f.filename}`);
        res.status(200).json({
            success: true,
            message: 'Files uploaded successfully',
            urls
        });
    });
};

router.post(
    '/challenge-images',
    protectAdmin,
    runArrayUpload(challengeImagesUpload.array('files', 15))
);

router.post(
    '/challenge-videos',
    protectAdmin,
    runArrayUpload(challengeVideosUpload.array('files', 10))
);

router.post('/', protectAdmin, upload.single('file'), (req, res) => {
    if (!req.file) {
        return res.status(400).json({ success: false, message: 'No file uploaded' });
    }

    const fileUrl = `/uploads/${req.file.filename}`;

    res.status(200).json({
        success: true,
        message: 'File uploaded successfully',
        url: fileUrl
    });
});

router.post('/gif', protectAdmin, (req, res, next) => {
    uploadGif.single('file')(req, res, (err) => {
        if (err) {
            return res.status(400).json({
                success: false,
                message: err.message || 'GIF upload failed'
            });
        }
        if (!req.file) {
            return res.status(400).json({ success: false, message: 'No file uploaded' });
        }
        const fileUrl = `/uploads/${req.file.filename}`;
        res.status(200).json({
            success: true,
            message: 'GIF uploaded successfully',
            url: fileUrl
        });
    });
});

module.exports = router;
