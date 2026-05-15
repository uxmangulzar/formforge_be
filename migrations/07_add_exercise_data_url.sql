-- Align exercises table with exerciseModel (data_url used by admin upload / CSV)
ALTER TABLE exercises ADD COLUMN data_url VARCHAR(255) NULL AFTER demo_url;
