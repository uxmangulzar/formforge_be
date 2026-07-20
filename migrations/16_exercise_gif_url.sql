-- Optional animated GIF for exercise demo (stored path under /uploads).

ALTER TABLE exercises
    ADD COLUMN gif_url VARCHAR(512) NULL AFTER demo_url;
