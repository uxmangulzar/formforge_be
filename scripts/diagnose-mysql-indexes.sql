-- Find tables near MySQL's 64-index limit (run on live DB via phpMyAdmin / mysql CLI)
SELECT
    TABLE_NAME,
    COUNT(DISTINCT INDEX_NAME) AS index_count
FROM information_schema.STATISTICS
WHERE TABLE_SCHEMA = DATABASE()
GROUP BY TABLE_NAME
HAVING index_count >= 50
ORDER BY index_count DESC;

-- List all indexes on the worst table (replace TABLE_NAME):
-- SHOW INDEX FROM your_table_name;
