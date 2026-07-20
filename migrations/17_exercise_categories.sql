-- Dynamic exercise categories (replaces ENUM exercises.category).

CREATE TABLE IF NOT EXISTS exercise_categories (
    id CHAR(36) NOT NULL PRIMARY KEY,
    slug VARCHAR(64) NOT NULL UNIQUE COMMENT 'Stable key for APIs & filters',
    display_name VARCHAR(120) NOT NULL COMMENT 'Admin / UI label',
    description VARCHAR(500) NULL,
    sort_order INT NOT NULL DEFAULT 0,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    createdAt DATETIME NOT NULL,
    updatedAt DATETIME NOT NULL,
    INDEX idx_exercise_categories_active_sort (is_active, sort_order)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT IGNORE INTO exercise_categories (id, slug, display_name, sort_order, is_active, createdAt, updatedAt)
VALUES
    ('a1111111-1111-4111-8111-111111111101', 'upper_body', 'Upper Body', 10, TRUE, NOW(), NOW()),
    ('a1111111-1111-4111-8111-111111111102', 'lower_body', 'Lower Body', 20, TRUE, NOW(), NOW()),
    ('a1111111-1111-4111-8111-111111111103', 'core', 'Core', 30, TRUE, NOW(), NOW()),
    ('a1111111-1111-4111-8111-111111111104', 'full_body', 'Full Body', 40, TRUE, NOW(), NOW());

ALTER TABLE exercises
    ADD COLUMN category_id CHAR(36) NULL AFTER type;

UPDATE exercises e
INNER JOIN exercise_categories c ON c.slug = e.category
SET e.category_id = c.id;

UPDATE exercises e
CROSS JOIN (SELECT id AS fb FROM exercise_categories WHERE slug = 'full_body' LIMIT 1) d
SET e.category_id = d.fb
WHERE e.category_id IS NULL;

ALTER TABLE exercises
    DROP COLUMN category,
    MODIFY COLUMN category_id CHAR(36) NOT NULL,
    ADD CONSTRAINT fk_exercises_exercise_category
        FOREIGN KEY (category_id) REFERENCES exercise_categories(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT;
