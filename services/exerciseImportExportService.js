const XLSX = require('xlsx');
const Exercise = require('../models/exerciseModel');
const ExerciseCategory = require('../models/exerciseCategoryModel');
const exerciseService = require('./exerciseService');

const EXPORT_COLUMNS = [
    'index',
    'name',
    'type',
    'category',
    'description',
    'demo_url',
    'gif_url',
    'data_url',
    'difficulty',
    'target_muscles',
    'logic_config',
    'rep_counting_logic',
    'is_active',
    'createdAt',
    'updatedAt'
];

const exerciseCategoryInclude = {
    model: ExerciseCategory,
    as: 'exerciseCategory',
    attributes: ['id', 'slug', 'display_name'],
    required: false
};

const jsonToCell = (value) => {
    if (value == null || value === '') return '';
    if (typeof value === 'string') return value;
    return JSON.stringify(value);
};

const parseJsonCell = (value, fieldName, rowNum) => {
    if (value == null || value === '') return null;
    if (typeof value === 'object') return value;
    const str = String(value).trim();
    if (!str) return null;
    try {
        return JSON.parse(str);
    } catch {
        throw new Error(`Row ${rowNum}: invalid JSON in ${fieldName}`);
    }
};

const parseBool = (value, defaultValue = true) => {
    if (value == null || value === '') return defaultValue;
    if (typeof value === 'boolean') return value;
    const s = String(value).trim().toLowerCase();
    if (['true', '1', 'yes', 'y'].includes(s)) return true;
    if (['false', '0', 'no', 'n'].includes(s)) return false;
    return defaultValue;
};

const normalizeHeader = (key) =>
    String(key || '')
        .trim()
        .toLowerCase()
        .replace(/\s+/g, '_');

const mapRowKeys = (row) => {
    const mapped = {};
    for (const [key, val] of Object.entries(row)) {
        mapped[normalizeHeader(key)] = val;
    }
    return mapped;
};

const toExportRow = (exercise, rowIndex) => {
    const plain = exercise.get ? exercise.get({ plain: true }) : exercise;
    const cat = plain.exerciseCategory || {};

    return {
        index: rowIndex + 1,
        name: plain.name || '',
        type: plain.type || '',
        category: cat.display_name || '',
        description: plain.description || '',
        demo_url: plain.demo_url || '',
        gif_url: plain.gif_url || '',
        data_url: plain.data_url || '',
        difficulty: plain.difficulty || 'beginner',
        target_muscles: jsonToCell(plain.target_muscles),
        logic_config: jsonToCell(plain.logic_config),
        rep_counting_logic: jsonToCell(plain.rep_counting_logic),
        is_active: plain.is_active !== false,
        createdAt: plain.createdAt ? new Date(plain.createdAt).toISOString() : '',
        updatedAt: plain.updatedAt ? new Date(plain.updatedAt).toISOString() : ''
    };
};

const buildWorkbookBuffer = (rows, format) => {
    const sheet = XLSX.utils.json_to_sheet(rows, { header: EXPORT_COLUMNS });
    const workbook = XLSX.utils.book_new();
    XLSX.utils.book_append_sheet(workbook, sheet, 'Exercises');

    if (format === 'csv') {
        const csv = XLSX.utils.sheet_to_csv(sheet);
        return {
            buffer: Buffer.from(csv, 'utf8'),
            contentType: 'text/csv; charset=utf-8',
            filename: `exercises_export_${dateStamp()}.csv`
        };
    }

    return {
        buffer: XLSX.write(workbook, { type: 'buffer', bookType: 'xlsx' }),
        contentType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        filename: `exercises_export_${dateStamp()}.xlsx`
    };
};

const dateStamp = () => {
    const d = new Date();
    const pad = (n) => String(n).padStart(2, '0');
    return `${d.getFullYear()}${pad(d.getMonth() + 1)}${pad(d.getDate())}_${pad(d.getHours())}${pad(d.getMinutes())}`;
};

const parseUploadRows = (buffer, format) => {
    const bookType = format === 'csv' ? 'string' : 'buffer';
    const workbook = XLSX.read(buffer, { type: bookType, cellDates: true });
    const sheetName = workbook.SheetNames[0];
    if (!sheetName) return [];
    return XLSX.utils.sheet_to_json(workbook.Sheets[sheetName], { defval: '' });
};

const rowToPayload = (rawRow, rowNum) => {
    const row = mapRowKeys(rawRow);
    const name = row.name != null ? String(row.name).trim() : '';
    if (!name) {
        throw new Error(`Row ${rowNum}: name is required`);
    }

    const type = row.type != null ? String(row.type).trim().toLowerCase() : '';
    if (!['train', 'play', 'recover'].includes(type)) {
        throw new Error(`Row ${rowNum}: type must be train, play, or recover`);
    }

    const difficulty =
        row.difficulty != null ? String(row.difficulty).trim().toLowerCase() : 'beginner';
    if (!['beginner', 'intermediate', 'advanced'].includes(difficulty)) {
        throw new Error(`Row ${rowNum}: invalid difficulty`);
    }

    const payload = {
        name,
        type,
        description: row.description != null ? String(row.description).trim() : null,
        demo_url: row.demo_url != null ? String(row.demo_url).trim() : null,
        gif_url: row.gif_url != null ? String(row.gif_url).trim() : null,
        data_url: row.data_url != null ? String(row.data_url).trim() : null,
        difficulty,
        target_muscles: parseJsonCell(row.target_muscles, 'target_muscles', rowNum),
        logic_config: parseJsonCell(row.logic_config, 'logic_config', rowNum),
        rep_counting_logic: parseJsonCell(row.rep_counting_logic, 'rep_counting_logic', rowNum),
        is_active: parseBool(row.is_active, true)
    };

    if (row.category_id != null && String(row.category_id).trim() !== '') {
        payload.category_id = String(row.category_id).trim();
    }
    if (row.category != null && String(row.category).trim() !== '') {
        payload.category = String(row.category).trim();
    }

    const id = row.id != null ? String(row.id).trim() : '';
    if (id) payload.id = id;

    return payload;
};

const exportExercises = async (format = 'csv') => {
    const fmt = String(format).toLowerCase();
    if (!['csv', 'xlsx'].includes(fmt)) {
        throw new Error('Export format must be csv or xlsx');
    }

    const exercises = await Exercise.findAll({
        include: [exerciseCategoryInclude],
        order: [['name', 'ASC']]
    });

    const rows = exercises.map((exercise, i) => toExportRow(exercise, i));
    return {
        ...buildWorkbookBuffer(rows, fmt),
        count: rows.length
    };
};

const getImportTemplate = async (format = 'csv') => {
    const fmt = String(format).toLowerCase();
    if (!['csv', 'xlsx'].includes(fmt)) {
        throw new Error('Template format must be csv or xlsx');
    }

    const sample = [
        {
            index: 1,
            name: 'Squats',
            type: 'train',
            category: 'Lower Body',
            description:
                'A fundamental lower body exercise that targets the quads, glutes, and hamstrings.',
            demo_url: 'https://example.com/squat.mp4',
            gif_url: '',
            data_url: '',
            difficulty: 'beginner',
            target_muscles: '["Quads","Glutes","Hamstrings"]',
            logic_config: '{"heel_contact":true,"max_back_lean":30}',
            rep_counting_logic: '{"state_a":"standing","state_b":"deep_squat","min_depth":90}',
            is_active: true,
            createdAt: '',
            updatedAt: ''
        }
    ];

    const built = buildWorkbookBuffer(sample, fmt);
    return {
        ...built,
        filename: `exercises_import_template.${fmt === 'csv' ? 'csv' : 'xlsx'}`
    };
};

const importExercises = async (buffer, format) => {
    const fmt = String(format).toLowerCase();
    if (!['csv', 'xlsx'].includes(fmt)) {
        throw new Error('Import format must be csv or xlsx');
    }

    const rawRows = parseUploadRows(buffer, fmt);
    if (!rawRows.length) {
        throw new Error('File is empty or has no data rows');
    }

    const summary = {
        total: rawRows.length,
        created: 0,
        updated: 0,
        skipped: 0,
        errors: []
    };

    for (let i = 0; i < rawRows.length; i++) {
        const rowNum = i + 2;
        try {
            const payload = rowToPayload(rawRows[i], rowNum);
            const { id, ...body } = payload;

            if (id) {
                const existing = await Exercise.findByPk(id);
                if (existing) {
                    await exerciseService.updateExercise(id, body);
                    summary.updated += 1;
                    continue;
                }
            }

            await exerciseService.createExercise(body);
            summary.created += 1;
        } catch (err) {
            summary.errors.push({ row: rowNum, message: err.message });
        }
    }

    return summary;
};

module.exports = {
    exportExercises,
    getImportTemplate,
    importExercises,
    EXPORT_COLUMNS
};
