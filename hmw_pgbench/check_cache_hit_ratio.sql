SELECT
    name AS parameter,
    setting AS value
FROM pg_settings
WHERE name = 'shared_buffers';

SELECT
    sum(blks_hit) / sum(blks_hit + blks_read) AS cache_hit_ratio
FROM pg_stat_database;

INSERT INTO test_table (data)
SELECT md5(random()::text) || md5(clock_timestamp()::text)
FROM generate_series(1, 5000000);

SELECT
    sum(blks_hit) / sum(blks_hit + blks_read) AS cache_hit_ratio
FROM pg_stat_database;