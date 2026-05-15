-- Admin: enable/disable a setting row without deleting (optional feature; safe default TRUE)
ALTER TABLE Settings
    ADD COLUMN is_active BOOLEAN NOT NULL DEFAULT TRUE AFTER description;
