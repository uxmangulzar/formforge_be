-- Challenge hero / gallery media: separate JSON arrays for images vs videos (URLs only).

ALTER TABLE challenges
    ADD COLUMN image_urls JSON NULL COMMENT 'Array of image URLs (strings)' AFTER description,
    ADD COLUMN video_urls JSON NULL COMMENT 'Array of video URLs (strings)' AFTER image_urls;
