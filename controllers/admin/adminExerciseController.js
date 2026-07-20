const exerciseImportExportService = require('../../services/exerciseImportExportService');

const detectFormat = (filename, queryFormat) => {
    const q = queryFormat ? String(queryFormat).toLowerCase() : '';
    if (q === 'csv' || q === 'xlsx') return q;
    const lower = String(filename || '').toLowerCase();
    if (lower.endsWith('.xlsx') || lower.endsWith('.xls')) return 'xlsx';
    if (lower.endsWith('.csv')) return 'csv';
    return null;
};

const exportAdminExercises = async (req, res, next) => {
    try {
        const format = detectFormat(null, req.query.format) || 'csv';
        const result = await exerciseImportExportService.exportExercises(format);

        res.setHeader('Content-Type', result.contentType);
        res.setHeader('Content-Disposition', `attachment; filename="${result.filename}"`);
        res.send(result.buffer);
    } catch (error) {
        if (error.message?.includes('format must be')) {
            res.status(400);
        }
        next(error);
    }
};

const downloadAdminExerciseTemplate = async (req, res, next) => {
    try {
        const format = detectFormat(null, req.query.format) || 'csv';
        const result = await exerciseImportExportService.getImportTemplate(format);

        res.setHeader('Content-Type', result.contentType);
        res.setHeader('Content-Disposition', `attachment; filename="${result.filename}"`);
        res.send(result.buffer);
    } catch (error) {
        if (error.message?.includes('format must be')) {
            res.status(400);
        }
        next(error);
    }
};

const importAdminExercises = async (req, res, next) => {
    try {
        if (!req.file || !req.file.buffer) {
            res.status(400);
            throw new Error('Upload a CSV or Excel (.xlsx) file');
        }

        const format =
            detectFormat(req.file.originalname, req.query.format) ||
            detectFormat(req.file.originalname, req.body?.format);

        if (!format) {
            res.status(400);
            throw new Error('Could not detect format. Use .csv or .xlsx, or pass ?format=csv|xlsx');
        }

        const summary = await exerciseImportExportService.importExercises(req.file.buffer, format);

        res.status(200).json({
            success: true,
            message: `Import finished: ${summary.created} created, ${summary.updated} updated`,
            data: summary
        });
    } catch (error) {
        if (
            error.message?.includes('Upload') ||
            error.message?.includes('detect') ||
            error.message?.includes('empty')
        ) {
            res.status(400);
        }
        next(error);
    }
};

module.exports = {
    exportAdminExercises,
    downloadAdminExerciseTemplate,
    importAdminExercises
};
