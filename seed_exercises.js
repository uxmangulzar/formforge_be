const { sequelize } = require('./database/db');
const Exercise = require('./models/exerciseModel');
const ExerciseCategory = require('./models/exerciseCategoryModel');

const seedExercises = async () => {
    try {
        await sequelize.authenticate();
        console.log('Database connected.');

        const categories = await ExerciseCategory.findAll({ attributes: ['id', 'slug'] });
        const slugToId = {};
        for (const c of categories) {
            slugToId[c.slug] = c.id;
        }

        const exercises = [
            {
                name: 'Squats',
                type: 'train',
                category: 'lower_body',
                difficulty: 'beginner',
                description:
                    'A fundamental lower body exercise that targets the quads, glutes, and hamstrings.',
                target_muscles: ['Quads', 'Glutes', 'Hamstrings'],
                logic_config: {
                    heel_contact: true,
                    max_back_lean: 30,
                    knee_alignment: 'toes'
                },
                rep_counting_logic: {
                    state_a: 'standing',
                    state_b: 'deep_squat',
                    min_depth: 90
                }
            },
            {
                name: 'Pushups',
                type: 'train',
                category: 'upper_body',
                difficulty: 'intermediate',
                description: 'A classic upper body exercise for chest, triceps, and shoulders.',
                target_muscles: ['Chest', 'Triceps', 'Shoulders'],
                logic_config: {
                    min_elbow_angle: 70,
                    body_straight: true,
                    hand_placement: 'shoulder_width'
                },
                rep_counting_logic: {
                    state_a: 'high_plank',
                    state_b: 'low_plank',
                    threshold: 0.5
                }
            },
            {
                name: 'Lunges',
                type: 'train',
                category: 'lower_body',
                difficulty: 'beginner',
                description: 'Unilateral lower body exercise for balance and strength.',
                target_muscles: ['Quads', 'Glutes', 'Hip Flexors'],
                logic_config: {
                    balance_stability: 0.8,
                    knee_angle_front: 90,
                    torso_upright: true
                },
                rep_counting_logic: {
                    count_per_leg: true,
                    alternating: true
                }
            },
            {
                name: 'Plank',
                type: 'train',
                category: 'core',
                difficulty: 'intermediate',
                description: 'Isometric core exercise for stability and endurance.',
                target_muscles: ['Abs', 'Lower Back', 'Shoulders'],
                logic_config: {
                    time_based: true,
                    hip_height_threshold: 0.2,
                    back_flatness: 0.9
                },
                rep_counting_logic: {
                    type: 'duration',
                    unit: 'seconds',
                    min_hold: 30
                }
            }
        ];

        for (const ex of exercises) {
            const category_id = slugToId[ex.category];
            if (!category_id) {
                console.error(
                    `Missing exercise_categories row for slug "${ex.category}". Run migration 17_exercise_categories.sql first.`
                );
                process.exit(1);
            }
            const { category, ...payload } = ex;
            const rowPayload = { ...payload, category_id };

            const existing = await Exercise.findOne({ where: { name: ex.name } });
            if (!existing) {
                await Exercise.create(rowPayload);
                console.log(`Created: ${ex.name}`);
            } else {
                await existing.update(rowPayload);
                console.log(`Updated: ${ex.name}`);
            }
        }

        console.log('Seeding complete!');
        process.exit(0);
    } catch (error) {
        console.error('Seeding failed:', error);
        process.exit(1);
    }
};

seedExercises();
