-- ============================================
-- Flink SQL Joins
-- ============================================
-- Join operations for streams and tables
-- Different join types for different use cases

-- ============================================
-- Setup: Create Source Tables
-- ============================================

-- Orders stream
CREATE TABLE Orders (
    order_id STRING,
    user_id STRING,
    product_id STRING,
    amount DECIMAL(10, 2),
    order_time TIMESTAMP(3),
    WATERMARK FOR order_time AS order_time - INTERVAL '5' SECOND
) WITH (
    'connector' = 'datagen',
    'rows-per-second' = '5',
    'fields.order_id.length' = '10',
    'fields.user_id.length' = '8',
    'fields.product_id.length' = '8',
    'fields.amount.min' = '10',
    'fields.amount.max' = '1000'
);

-- Shipments stream
CREATE TABLE Shipments (
    shipment_id STRING,
    order_id STRING,
    carrier STRING,
    shipment_time TIMESTAMP(3),
    WATERMARK FOR shipment_time AS shipment_time - INTERVAL '5' SECOND
) WITH (
    'connector' = 'datagen',
    'rows-per-second' = '3',
    'fields.shipment_id.length' = '10',
    'fields.order_id.length' = '10',
    'fields.carrier.length' = '5'
);

-- Users dimension table (slowly changing)
CREATE TABLE Users (
    user_id STRING,
    username STRING,
    email STRING,
    country STRING,
    PRIMARY KEY (user_id) NOT ENFORCED
) WITH (
    'connector' = 'upsert-kafka',
    'topic' = 'users',
    'properties.bootstrap.servers' = 'kafka:29092',
    'key.format' = 'json',
    'value.format' = 'json'
);

-- Products dimension table
CREATE TABLE Products (
    product_id STRING,
    product_name STRING,
    category STRING,
    price DECIMAL(10, 2),
    PRIMARY KEY (product_id) NOT ENFORCED
) WITH (
    'connector' = 'upsert-kafka',
    'topic' = 'products',
    'properties.bootstrap.servers' = 'kafka:29092',
    'key.format' = 'json',
    'value.format' = 'json'
);

-- ============================================
-- 1. INNER JOIN (Regular Join)
-- ============================================

-- Join orders with shipments - only matched records
-- Note: In streaming, this creates a join state that grows unbounded
SELECT 
    o.order_id,
    o.user_id,
    o.amount,
    o.order_time,
    s.shipment_id,
    s.carrier,
    s.shipment_time
FROM Orders o
INNER JOIN Shipments s
    ON o.order_id = s.order_id
LIMIT 10;

-- ============================================
-- 2. LEFT JOIN
-- ============================================

-- All orders, with shipment info if available
SELECT 
    o.order_id,
    o.user_id,
    o.amount,
    s.shipment_id,
    s.carrier,
    CASE 
        WHEN s.shipment_id IS NULL THEN 'Not Shipped'
        ELSE 'Shipped'
    END AS status
FROM Orders o
LEFT JOIN Shipments s
    ON o.order_id = s.order_id
LIMIT 10;

-- ============================================
-- 3. INTERVAL JOIN (Time-Bounded Join)
-- ============================================

-- Join orders with shipments that occur within specific time range
-- This prevents unbounded state growth
SELECT 
    o.order_id,
    o.user_id,
    o.amount,
    o.order_time,
    s.shipment_id,
    s.carrier,
    s.shipment_time,
    TIMESTAMPDIFF(MINUTE, o.order_time, s.shipment_time) AS minutes_to_ship
FROM Orders o
INNER JOIN Shipments s
    ON o.order_id = s.order_id
    AND s.shipment_time BETWEEN o.order_time AND o.order_time + INTERVAL '2' HOUR
LIMIT 10;

-- Find orders shipped within 30 minutes
SELECT 
    o.order_id,
    o.amount,
    s.carrier,
    TIMESTAMPDIFF(MINUTE, o.order_time, s.shipment_time) AS minutes_to_ship
FROM Orders o
INNER JOIN Shipments s
    ON o.order_id = s.order_id
    AND s.shipment_time BETWEEN o.order_time AND o.order_time + INTERVAL '30' MINUTE
WHERE TIMESTAMPDIFF(MINUTE, o.order_time, s.shipment_time) <= 30;

-- ============================================
-- 4. LOOKUP JOIN (Dimension Table Join)
-- ============================================

-- Join orders with user dimension table
-- More efficient for dimension lookups (doesn't keep all dimension history in state)
SELECT 
    o.order_id,
    o.user_id,
    u.username,
    u.email,
    u.country,
    o.amount,
    o.order_time
FROM Orders o
LEFT JOIN Users FOR SYSTEM_TIME AS OF o.order_time AS u
    ON o.user_id = u.user_id
LIMIT 10;

-- Join with multiple dimension tables
SELECT 
    o.order_id,
    u.username,
    u.country,
    p.product_name,
    p.category,
    o.amount,
    p.price
FROM Orders o
LEFT JOIN Users FOR SYSTEM_TIME AS OF o.order_time AS u
    ON o.user_id = u.user_id
LEFT JOIN Products FOR SYSTEM_TIME AS OF o.order_time AS p
    ON o.product_id = p.product_id
LIMIT 10;

-- ============================================
-- 5. WINDOWED JOIN
-- ============================================

-- Aggregate both streams first, then join
SELECT 
    o_agg.user_id,
    o_agg.window_start,
    o_agg.order_count,
    o_agg.total_amount,
    COALESCE(s_agg.shipment_count, 0) AS shipment_count
FROM (
    SELECT 
        user_id,
        TUMBLE_START(order_time, INTERVAL '1' MINUTE) AS window_start,
        TUMBLE_END(order_time, INTERVAL '1' MINUTE) AS window_end,
        COUNT(*) AS order_count,
        SUM(amount) AS total_amount
    FROM Orders
    GROUP BY user_id, TUMBLE(order_time, INTERVAL '1' MINUTE)
) o_agg
LEFT JOIN (
    SELECT 
        o.user_id,
        TUMBLE_START(s.shipment_time, INTERVAL '1' MINUTE) AS window_start,
        TUMBLE_END(s.shipment_time, INTERVAL '1' MINUTE) AS window_end,
        COUNT(*) AS shipment_count
    FROM Shipments s
    INNER JOIN Orders o ON s.order_id = o.order_id
    GROUP BY o.user_id, TUMBLE(s.shipment_time, INTERVAL '1' MINUTE)
) s_agg
    ON o_agg.user_id = s_agg.user_id
    AND o_agg.window_start = s_agg.window_start;

-- ============================================
-- 6. LATERAL JOIN (Table Function Join)
-- ============================================

-- Split and join (useful for unnesting arrays or complex types)
-- Example: Exploding a comma-separated field
CREATE TEMPORARY FUNCTION split_string AS 'org.apache.flink.table.functions.BuiltInFunctionDefinitions.SPLIT';

-- Join with table function to expand data
SELECT 
    o.order_id,
    o.user_id,
    o.amount,
    tag
FROM Orders o
CROSS JOIN UNNEST(SPLIT(o.product_id, ',')) AS t(tag);

-- ============================================
-- 7. SELF JOIN
-- ============================================

-- Find orders from same user
SELECT 
    o1.order_id AS order1,
    o2.order_id AS order2,
    o1.user_id,
    o1.amount AS amount1,
    o2.amount AS amount2,
    TIMESTAMPDIFF(MINUTE, o1.order_time, o2.order_time) AS minutes_between
FROM Orders o1
INNER JOIN Orders o2
    ON o1.user_id = o2.user_id
    AND o1.order_id <> o2.order_id
    AND o2.order_time BETWEEN o1.order_time AND o1.order_time + INTERVAL '1' HOUR
LIMIT 10;

-- ============================================
-- 8. ANTI JOIN (Find Non-Matching Records)
-- ============================================

-- Find orders without shipments
SELECT o.*
FROM Orders o
WHERE NOT EXISTS (
    SELECT 1 FROM Shipments s
    WHERE s.order_id = o.order_id
)
LIMIT 10;

-- Using LEFT JOIN with NULL check
SELECT o.*
FROM Orders o
LEFT JOIN Shipments s ON o.order_id = s.order_id
WHERE s.shipment_id IS NULL
LIMIT 10;

-- ============================================
-- 9. SEMI JOIN (Find Matching Records Without Duplicates)
-- ============================================

-- Find users who have placed orders
SELECT DISTINCT u.*
FROM Users u
WHERE EXISTS (
    SELECT 1 FROM Orders o
    WHERE o.user_id = u.user_id
);

-- ============================================
-- 10. Multiple Stream Join
-- ============================================

-- Join 3 streams: Orders, Shipments, and create a Returns stream
CREATE TABLE Returns (
    return_id STRING,
    order_id STRING,
    reason STRING,
    return_time TIMESTAMP(3),
    WATERMARK FOR return_time AS return_time - INTERVAL '5' SECOND
) WITH (
    'connector' = 'datagen',
    'rows-per-second' = '1',
    'fields.return_id.length' = '10',
    'fields.order_id.length' = '10',
    'fields.reason.length' = '20'
);

-- Join all three streams
SELECT 
    o.order_id,
    o.user_id,
    o.amount,
    o.order_time,
    s.shipment_id,
    s.shipment_time,
    r.return_id,
    r.reason,
    r.return_time
FROM Orders o
LEFT JOIN Shipments s
    ON o.order_id = s.order_id
    AND s.shipment_time BETWEEN o.order_time AND o.order_time + INTERVAL '7' DAY
LEFT JOIN Returns r
    ON o.order_id = r.order_id
    AND r.return_time BETWEEN o.order_time AND o.order_time + INTERVAL '30' DAY
LIMIT 10;

-- ============================================
-- 11. Join with Aggregation
-- ============================================

-- Orders with user statistics
SELECT 
    o.order_id,
    o.user_id,
    u.username,
    o.amount,
    user_stats.total_orders,
    user_stats.total_spent
FROM Orders o
LEFT JOIN Users FOR SYSTEM_TIME AS OF o.order_time AS u
    ON o.user_id = u.user_id
LEFT JOIN (
    SELECT 
        user_id,
        COUNT(*) AS total_orders,
        SUM(amount) AS total_spent
    FROM Orders
    GROUP BY user_id
) user_stats
    ON o.user_id = user_stats.user_id
LIMIT 10;

-- ============================================
-- 12. Temporal Join (Time-Versioned)
-- ============================================

-- Join with the version of dimension table valid at order time
-- Most efficient for slowly changing dimensions
SELECT 
    o.order_id,
    o.order_time,
    p.product_name,
    p.price AS price_at_order_time,
    o.amount
FROM Orders o
LEFT JOIN Products FOR SYSTEM_TIME AS OF o.order_time AS p
    ON o.product_id = p.product_id
WHERE p.category = 'Electronics'
LIMIT 10;

-- ============================================
-- Join Best Practices
-- ============================================

-- 1. Use INTERVAL JOIN to bound join state
-- 2. Use LOOKUP JOIN for dimension tables
-- 3. Use TEMPORAL JOIN for time-versioned lookups
-- 4. Define appropriate watermarks
-- 5. Set state TTL for unbounded joins
-- 6. Monitor join state size
-- 7. Consider windowed aggregation before joining

-- ============================================
-- Monitoring Join State
-- ============================================

-- Check if joins are causing state growth:
-- View in Flink Web UI: localhost:8081
-- Check metrics: numRecordsIn, numRecordsOut, state size

-- ============================================
-- Cleanup
-- ============================================

-- DROP TABLE Orders;
-- DROP TABLE Shipments;
-- DROP TABLE Users;
-- DROP TABLE Products;
-- DROP TABLE Returns;

-- ============================================
-- Next Steps
-- ============================================
-- Try:
-- 1. advanced.sql - Pattern matching, Top-N, and deduplication
-- 2. Optimize join performance with proper watermarks
-- 3. Monitor state size in production
