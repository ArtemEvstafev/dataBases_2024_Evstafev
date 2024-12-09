DO

$$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'pgbench_accounts') THEN
        CREATE TABLE pgbench_accounts (
            aid INT PRIMARY KEY,
            bid INT,
            abalance INT,
            filler TEXT
        );
    END IF;
END

$$;

\set aid random(1, 2000000)
WITH cte AS (
    SELECT :aid AS new_aid
    FROM pgbench_accounts
    WHERE aid = :aid
    FOR UPDATE SKIP LOCKED
)
INSERT INTO pgbench_accounts (aid, bid, abalance, filler)
SELECT :aid, :aid % 100, :aid * 10, ''
FROM cte
WHERE cte.new_aid IS NULL;
