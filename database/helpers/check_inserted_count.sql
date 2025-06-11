-- Source: https://www.w3resource.com/PostgreSQL/snippets/find-row-count-for-tables-postgresql.php
SELECT relname AS table_name, n_live_tup AS row_count
FROM pg_stat_user_tables
ORDER BY table_name;
