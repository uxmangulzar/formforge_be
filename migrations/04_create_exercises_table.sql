-- Create Exercises Table
CREATE TABLE IF NOT EXISTS exercises (
    id CHAR(36) NOT NULL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    type ENUM('train', 'play', 'recover') NOT NULL,
    category ENUM('upper_body', 'lower_body', 'core', 'full_body') NOT NULL,
    description TEXT,
    demo_url VARCHAR(255),
    difficulty ENUM('beginner', 'intermediate', 'advanced') DEFAULT 'beginner',
    target_muscles JSON,
    logic_config JSON,
    rep_counting_logic JSON,
    is_active BOOLEAN DEFAULT TRUE,
    createdAt DATETIME NOT NULL,
    updatedAt DATETIME NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Insert Initial Exercises Data
INSERT INTO exercises (id, name, type, category, description, demo_url, difficulty, target_muscles, logic_config, rep_counting_logic, is_active, createdAt, updatedAt) 
VALUES 
(
    UUID(), 
    'Standard Squat', 
    'train', 
    'lower_body', 
    'Keep your feet shoulder-width apart. Lower your hips as if sitting in a chair, keeping your chest up and back straight.', 
    'https://assets.formforge.ai/exercises/squat.mp4', 
    'beginner', 
    '["Quads", "Glutes", "Hamstrings"]', 
    '{"min_knee_angle": 90, "max_back_lean": 30, "heel_contact": true}', 
    '{"state_a": "standing", "state_b": "descending", "state_c": "squat_point", "threshold": 100}', 
    1, 
    NOW(), 
    NOW()
),
(
    UUID(), 
    'Push-up', 
    'train', 
    'upper_body', 
    'Start in a plank position. Lower your body until your chest nearly touches the floor, then push back up.', 
    'https://assets.formforge.ai/exercises/pushup.mp4', 
    'beginner', 
    '["Chest", "Triceps", "Shoulders"]', 
    '{"min_elbow_angle": 70, "body_straightness_threshold": 165}', 
    '{"state_a": "high_plank", "state_b": "lowering", "state_c": "bottom_point"}', 
    1, 
    NOW(), 
    NOW()
),
(
    UUID(), 
    'Walking Lunge', 
    'train', 
    'lower_body', 
    'Step forward with one leg and lower your hips until both knees are bent at a 90-degree angle.', 
    'https://assets.formforge.ai/exercises/lunge.mp4', 
    'intermediate', 
    '["Quads", "Glutes", "Hip Flexors"]', 
    '{"knee_angle_target": 90, "balance_stability": 0.8}', 
    '{"count_per_leg": true}', 
    1, 
    NOW(), 
    NOW()
),
(
    UUID(), 
    'Plank', 
    'train', 
    'core', 
    'Maintain a straight line from head to heels while resting on your forearms and toes.', 
    'https://assets.formforge.ai/exercises/plank.mp4', 
    'beginner', 
    '["Abs", "Lower Back", "Shoulders"]', 
    '{"hip_height_threshold": "aligned", "time_based": true}', 
    '{"type": "duration", "unit": "seconds"}', 
    1, 
    NOW(), 
    NOW()
);
