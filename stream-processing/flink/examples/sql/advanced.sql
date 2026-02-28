-- ============================================
-- Flink SQL Advanced Features
-- ============================================
-- Pattern matching, Top-N, deduplication, UDFs, and more

-- ============================================
-- Setup: Create Source Tables
-- ============================================

-- User activity stream
CREATE TABLE user_events (
    user_id STRING,
    event_type STRING,
    event_value DOUBLE,
    event_time TIMESTAMP(3),
    WATERMARK FOR event_time AS event_time - INTERVAL '5' SECOND
) WITH (
    'connector' = 'datagen',
    'rows-per-second' = '10',
    'fields.user_id.length' = '8',
    'fields.event_type.length' = '10',
    'fields.event_value.min' = '1',
    'fields.event_value.max' = '100'
);

-- Product prices
CREATE TABLE product_prices (
    product_id STRING,
    price DOUBLE,
    update_time TIMESTAMP(3),
    WATERMARK FOR update_time AS update_time - INTERVAL '5' SECOND
) WITH (
    'connector' = 'datagen',
    'rows-per-second' = '5',
    'fields.product_id.length' = '8',
    'fields.price.min' = '10',
    'fields.price.max' = '1000'
);

-- ============================================
-- 1. DEDUPLICATION (Remove Duplicates)
-- ============================================

-- Keep first occurrence of each user's event
SELECT user_id, event_type, event_value, event_time
FROM (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY user_id
            ORDER BY event_time ASC
        ) AS row_num
    FROM user_events
)
WHERE row_num = 1;

-- Keep latest event for each user (deduplication by keeping last)
SELECT user_id, event_type, event_value, event_time
FROM (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY user_id
            ORDER BY event_time DESC
        ) AS row_num
    FROM user_events
)
WHERE row_num = 1;

-- Deduplicate within time window (e.g., last 1 minute)
SELECT user_id, event_type, event_value, event_time
FROM (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY user_id
            ORDER BY event_time DESC
        ) AS row_num
    FROM user_events
)
WHERE row_num = 1;

-- ============================================
-- 2. TOP-N (Find Top K per Group)
-- ============================================

-- Top 3 events per user by value
SELECT *
FROM (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY user_id
            ORDER BY event_value DESC
        ) AS rank_num
    FROM user_events
)
WHERE rank_num <= 3;

-- Top 5 users by total event value (windowed)
SELECT *
FROM (
    SELECT 
        user_id,
        window_start,
        total_value,
        ROW_NUMBER() OVER (
            PARTITION BY window_start
            ORDER BY total_value DESC
        ) AS rank_num
    FROM (
        SELECT 
            user_id,
            TUMBLE_START(event_time, INTERVAL '1' MINUTE) AS window_start,
            SUM(event_value) AS total_value
        FROM user_events
        GROUP BY user_id, TUMBLE(event_time, INTERVAL '1' MINUTE)
    )
)
WHERE rank_num <= 5;

-- Top products by price change
SELECT *
FROM (
    SELECT *,
        RANK() OVER (
            ORDER BY price DESC
        ) AS price_rank
    FROM product_prices
)
WHERE price_rank <= 10;

-- ============================================
-- 3. MATCH_RECOGNIZE (Pattern Matching - CEP)
-- ============================================

-- Detect pattern: Three consecutive increasing prices for same product
SELECT *
FROM product_prices
MATCH_RECOGNIZE (
    PARTITION BY product_id
    ORDER BY update_time
    MEASURES
        FIRST(A.update_time) AS start_time,
        LAST(C.update_time) AS end_time,
        FIRST(A.price) AS start_price,
        LAST(C.price) AS end_price,
        LAST(C.price) - FIRST(A.price) AS price_increase
    ONE ROW PER MATCH
    AFTER MATCH SKIP PAST LAST ROW
    PATTERN (A B C)
    DEFINE
        B AS B.price > A.price,
        C AS C.price > B.price
) AS T;

-- Detect user behavior pattern: login -> view -> purchase
SELECT *
FROM user_events
MATCH_RECOGNIZE (
    PARTITION BY user_id
    ORDER BY event_time
    MEASURES
        FIRST(LOGIN.event_time) AS login_time,
        LAST(PURCHASE.event_time) AS purchase_time,
        PURCHASE.event_value AS purchase_amount
    ONE ROW PER MATCH
    AFTER MATCH SKIP TO NEXT ROW
    PATTERN (LOGIN VIEW+ PURCHASE)
    WITHIN INTERVAL '30' MINUTE
    DEFINE
        LOGIN AS LOGIN.event_type = 'login',
        VIEW AS VIEW.event_type = 'view',
        PURCHASE AS PURCHASE.event_type = 'purchase'
) AS T;

-- Detect anomaly: Sharp price drop
SELECT *
FROM product_prices
MATCH_RECOGNIZE (
    PARTITION BY product_id
    ORDER BY update_time
    MEASURES
        FIRST(NORMAL.price) AS before_price,
        LAST(DROP.price) AS after_price,
        (FIRST(NORMAL.price) - LAST(DROP.price)) / FIRST(NORMAL.price) * 100 AS drop_percentage
    ONE ROW PER MATCH
    AFTER MATCH SKIP PAST LAST ROW
    PATTERN (NORMAL+ DROP)
    DEFINE
        NORMAL AS NORMAL.price > 0,
        DROP AS DROP.price < PREV(DROP.price) * 0.8  -- 20% drop
) AS T;

-- ============================================
-- 4. WINDOW TOP-N with Deduplication
-- ============================================

-- Most active users per minute (deduplicated and ranked)
CREATE VIEW TopUsersByMinute AS
SELECT 
    window_start,
    user_id,
    event_count,
    rank_num
FROM (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY window_start
            ORDER BY event_count DESC
        ) AS rank_num
    FROM (
        SELECT 
            user_id,
            TUMBLE_START(event_time, INTERVAL '1' MINUTE) AS window_start,
            COUNT(*) AS event_count
        FROM user_events
        GROUP BY user_id, TUMBLE(event_time, INTERVAL '1' MINUTE)
    )
)
WHERE rank_num <= 10;

SELECT * FROM TopUsersByMinute;

-- ============================================
-- 5. LATERAL VIEW (Unnesting)
-- ============================================

-- Create table with array field
CREATE TABLE user_tags (
    user_id STRING,
    tags ARRAY<STRING>,
    event_time TIMESTAMP(3)
) WITH (
    'connector' = 'datagen',
    'rows-per-second' = '3'
);

-- Unnest array to individual rows
SELECT 
    user_id,
    tag,
    event_time
FROM user_tags
CROSS JOIN UNNEST(tags) AS t(tag);

-- Count occurrences of each tag
SELECT 
    tag,
    COUNT(*) AS tag_count
FROM user_tags
CROSS JOIN UNNEST(tags) AS t(tag)
GROUP BY tag;

-- ============================================
-- 6. GROUPING SETS, CUBE, and ROLLUP
-- ============================================

-- Multiple aggregation levels in one query
SELECT 
    user_id,
    event_type,
    COUNT(*) AS event_count,
    SUM(event_value) AS total_value
FROM user_events
GROUP BY GROUPING SETS (
    (user_id, event_type),  -- Per user and event type
    (user_id),               -- Per user (all event types)
    (event_type),            -- Per event type (all users)
    ()                       -- Grand total
);

-- CUBE: All possible combinations
SELECT 
    user_id,
    event_type,
    COUNT(*) AS event_count
FROM user_events
GROUP BY CUBE (user_id, event_type);

-- ROLLUP: Hierarchical aggregation
SELECT 
    event_type,
    user_id,
    COUNT(*) AS event_count
FROM user_events
GROUP BY ROLLUP (event_type, user_id);

-- ============================================
-- 7. OVER Windows (Analytical Functions)
-- ============================================

-- Running total
SELECT 
    user_id,
    event_time,
    event_value,
    SUM(event_value) OVER (
        PARTITION BY user_id
        ORDER BY event_time
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_total
FROM user_events;

-- Moving average (last 5 events)
SELECT 
    user_id,
    event_time,
    event_value,
    AVG(event_value) OVER (
        PARTITION BY user_id
        ORDER BY event_time
        ROWS BETWEEN 4 PRECEDING AND CURRENT ROW
    ) AS moving_avg_5
FROM user_events;

-- Rank, Dense Rank, Row Number
SELECT 
    user_id,
    event_value,
    event_time,
    ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY event_value DESC) AS row_num,
    RANK() OVER (PARTITION BY user_id ORDER BY event_value DESC) AS rank_num,
    DENSE_RANK() OVER (PARTITION BY user_id ORDER BY event_value DESC) AS dense_rank_num
FROM user_events;

-- Lead and Lag (access future/previous rows)
SELECT 
    product_id,
    update_time,
    price AS current_price,
    LAG(price, 1) OVER (PARTITION BY product_id ORDER BY update_time) AS previous_price,
    LEAD(price, 1) OVER (PARTITION BY product_id ORDER BY update_time) AS next_price,
    price - LAG(price, 1) OVER (PARTITION BY product_id ORDER BY update_time) AS price_change
FROM product_prices;

-- ============================================
-- 8. PIVOT Operations (Conditional Aggregation)
-- ============================================

-- Pivot event types into columns
SELECT 
    user_id,
    SUM(CASE WHEN event_type = 'login' THEN 1 ELSE 0 END) AS login_count,
    SUM(CASE WHEN event_type = 'view' THEN 1 ELSE 0 END) AS view_count,
    SUM(CASE WHEN event_type = 'purchase' THEN 1 ELSE 0 END) AS purchase_count,
    SUM(event_value) AS total_value
FROM user_events
GROUP BY user_id;

-- ============================================
-- 9. FIRST_VALUE and LAST_VALUE
-- ============================================

-- First and last event per user
SELECT 
    user_id,
    event_time,
    event_value,
    FIRST_VALUE(event_value) OVER (
        PARTITION BY user_id
        ORDER BY event_time
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS first_value,
    LAST_VALUE(event_value) OVER (
        PARTITION BY user_id
        ORDER BY event_time
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS last_value
FROM user_events;

-- ============================================
-- 10. Complex Aggregations
-- ============================================

-- Percentiles (approximate)
SELECT 
    user_id,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY event_value) AS median_value,
    PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY event_value) AS p95_value
FROM user_events
GROUP BY user_id;

-- Count distinct with window
SELECT 
    TUMBLE_START(event_time, INTERVAL '1' MINUTE) AS window_start,
    COUNT(DISTINCT user_id) AS unique_users,
    COUNT(DISTINCT event_type) AS unique_event_types,
    COUNT(*) AS total_events
FROM user_events
GROUP BY TUMBLE(event_time, INTERVAL '1' MINUTE);

-- ============================================
-- 11. State TTL Configuration
-- ============================================

-- Create table with state TTL (cleanup old state)
CREATE TABLE events_with_ttl (
    event_id STRING,
    data STRING,
    event_time TIMESTAMP(3),
    WATERMARK FOR event_time AS event_time - INTERVAL '5' SECOND
) WITH (
    'connector' = 'kafka',
    'topic' = 'events-ttl',
    'properties.bootstrap.servers' = 'kafka:29092',
    'format' = 'json'
);

-- Note: State TTL is configured at job level, not in SQL
-- Add to flink-conf.yaml or job configuration:
-- table.exec.state.ttl: 1 h

-- ============================================
-- 12. Dynamic Table Insert
-- ============================================

-- Create sink table
CREATE TABLE aggregated_results (
    user_id STRING,
    window_start TIMESTAMP(3),
    event_count BIGINT,
    total_value DOUBLE,
    avg_value DOUBLE,
    PRIMARY KEY (user_id, window_start) NOT ENFORCED
) WITH (
    'connector' = 'upsert-kafka',
    'topic' = 'aggregated-results',
    'properties.bootstrap.servers' = 'kafka:29092',
    'key.format' = 'json',
    'value.format' = 'json'
);

-- Continuous insert with aggregation
INSERT INTO aggregated_results
SELECT 
    user_id,
    TUMBLE_START(event_time, INTERVAL '1' MINUTE) AS window_start,
    COUNT(*) AS event_count,
    SUM(event_value) AS total_value,
    AVG(event_value) AS avg_value
FROM user_events
GROUP BY 
    user_id,
    TUMBLE(event_time, INTERVAL '1' MINUTE);

-- ============================================
-- 13. QUALIFY Clause (Filter Window Results)
-- ============================================

-- Filter based on window function results (alternative to subquery)
-- Note: QUALIFY is available in newer Flink versions
SELECT 
    user_id,
    event_value,
    event_time
FROM user_events
QUALIFY ROW_NUMBER() OVER (
    PARTITION BY user_id
    ORDER BY event_value DESC
) <= 3;

-- ============================================
-- 14. Statement Sets (Multiple Inserts)
-- ============================================

-- Execute multiple INSERT statements as one job
-- Note: Use STATEMENT SET in SQL Client

/*
STATEMENT SET
BEGIN

INSERT INTO aggregated_results
SELECT user_id, window_start, event_count, total_value, avg_value
FROM ...;

INSERT INTO another_sink
SELECT ...
FROM ...;

END;
*/

-- ============================================
-- 15. Temporal Functions
-- ============================================

-- Current timestamp functions
SELECT 
    event_time,
    CURRENT_TIMESTAMP AS processing_time,
    LOCALTIMESTAMP AS local_time,
    CURRENT_DATE AS current_date,
    CURRENT_TIME AS current_time
FROM user_events
LIMIT 5;

-- Date arithmetic
SELECT 
    event_time,
    event_time + INTERVAL '1' HOUR AS one_hour_later,
    event_time - INTERVAL '1' DAY AS one_day_before,
    TIMESTAMPADD(MINUTE, 30, event_time) AS thirty_min_later,
    TIMESTAMPDIFF(HOUR, event_time, CURRENT_TIMESTAMP) AS hours_since_event
FROM user_events
LIMIT 5;

-- ============================================
-- Performance Tips
-- ============================================

-- 1. Use appropriate watermarks
-- 2. Configure state TTL for unbounded aggregations
-- 3. Use incremental aggregations when possible
-- 4. Optimize join order (smaller stream first)
-- 5. Use LOOKUP JOIN for dimension tables
-- 6. Monitor state size in Flink UI
-- 7. Set appropriate parallelism
-- 8. Use async I/O for external lookups
-- 9. Configure checkpointing
-- 10. Use RocksDB for large state

-- ============================================
-- Cleanup
-- ============================================

-- DROP TABLE user_events;
-- DROP TABLE product_prices;
-- DROP TABLE user_tags;
-- DROP TABLE events_with_ttl;
-- DROP TABLE aggregated_results;
-- DROP VIEW TopUsersByMinute;

-- ============================================
-- Additional Resources
-- ============================================

-- Flink SQL Docs: https://nightlies.apache.org/flink/flink-docs-stable/docs/dev/table/sql/
-- Pattern Matching: https://nightlies.apache.org/flink/flink-docs-stable/docs/dev/table/sql/queries/match_recognize/
-- Window Functions: https://nightlies.apache.org/flink/flink-docs-stable/docs/dev/table/sql/queries/window-agg/
-- Performance Tuning: https://nightlies.apache.org/flink/flink-docs-stable/docs/dev/table/tuning/

-- ============================================
-- Congratulations!
-- ============================================
-- You've completed all Flink SQL examples:
-- ✓ basics.sql - SQL fundamentals
-- ✓ kafka_integration.sql - Kafka connectors
-- ✓ window_aggregations.sql - Time windows
-- ✓ joins.sql - Stream and table joins
-- ✓ advanced.sql - Advanced features (this file)
--
-- Next: Build your own streaming application!
