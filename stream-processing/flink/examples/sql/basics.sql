-- ============================================
-- Flink SQL Basics
-- ============================================
-- Introduction to Flink SQL fundamentals
-- Run in Flink SQL Client

-- ============================================
-- 1. Simple Table Creation (in-memory)
-- ============================================

-- Create a table with generated data
CREATE TABLE Orders (
    order_id INT,
    customer_id INT,
    product STRING,
    amount DECIMAL(10, 2),
    order_time TIMESTAMP(3),
    WATERMARK FOR order_time AS order_time - INTERVAL '5' SECOND
) WITH (
    'connector' = 'datagen',
    'rows-per-second' = '5',
    'fields.order_id.kind' = 'sequence',
    'fields.order_id.start' = '1',
    'fields.customer_id.min' = '1',
    'fields.customer_id.max' = '100',
    'fields.amount.min' = '10',
    'fields.amount.max' = '1000'
);

-- View table structure
DESCRIBE Orders;

-- ============================================
-- 2. Basic SELECT Queries
-- ============================================

-- Select all columns
SELECT * FROM Orders LIMIT 10;

-- Select specific columns
SELECT order_id, product, amount FROM Orders LIMIT 10;

-- Filter with WHERE
SELECT * FROM Orders 
WHERE amount > 500 
LIMIT 10;

-- ============================================
-- 3. Transformations
-- ============================================

-- Calculate with expressions
SELECT 
    order_id,
    amount,
    amount * 0.9 AS discounted_amount,
    amount * 0.1 AS discount
FROM Orders
LIMIT 10;

-- String functions
SELECT 
    order_id,
    product,
    UPPER(product) AS product_upper,
    LENGTH(product) AS product_length
FROM Orders
LIMIT 10;

-- Date/Time functions
SELECT 
    order_id,
    order_time,
    DATE_FORMAT(order_time, 'yyyy-MM-dd') AS order_date,
    HOUR(order_time) AS order_hour
FROM Orders
LIMIT 10;

-- ============================================
-- 4. Aggregations
-- ============================================

-- Note: For streaming queries, you need a GROUP BY with time window
-- For batch-like results, we can use processing time windows

-- Create a view for aggregation
CREATE TEMPORARY VIEW OrderStats AS
SELECT 
    customer_id,
    COUNT(*) AS order_count,
    SUM(amount) AS total_amount,
    AVG(amount) AS avg_amount,
    MIN(amount) AS min_amount,
    MAX(amount) AS max_amount
FROM Orders
GROUP BY customer_id;

-- Query the view (top customers by total amount)
SELECT * FROM OrderStats
ORDER BY total_amount DESC
LIMIT 10;

-- ============================================
-- 5. Filtering and Conditions
-- ============================================

-- CASE statement
SELECT 
    order_id,
    amount,
    CASE 
        WHEN amount < 100 THEN 'Small'
        WHEN amount < 500 THEN 'Medium'
        ELSE 'Large'
    END AS order_size
FROM Orders
LIMIT 10;

-- IN clause
SELECT * FROM Orders
WHERE customer_id IN (1, 5, 10)
LIMIT 10;

-- BETWEEN clause
SELECT * FROM Orders
WHERE amount BETWEEN 100 AND 500
LIMIT 10;

-- ============================================
-- 6. NULL Handling
-- ============================================

-- Check for NULL
SELECT 
    order_id,
    product,
    CASE WHEN product IS NULL THEN 'No Product' ELSE product END AS product_name
FROM Orders
LIMIT 10;

-- COALESCE (returns first non-null value)
SELECT 
    order_id,
    COALESCE(product, 'Unknown') AS product_name
FROM Orders
LIMIT 10;

-- ============================================
-- 7. Built-in Functions
-- ============================================

-- Mathematical functions
SELECT 
    amount,
    ROUND(amount, 0) AS rounded,
    CEIL(amount) AS ceiling,
    FLOOR(amount) AS floor,
    ABS(amount - 500) AS distance_from_500
FROM Orders
LIMIT 10;

-- String functions
SELECT 
    product,
    CONCAT('Product: ', product) AS labeled,
    SUBSTRING(product, 1, 5) AS short_name,
    LOWER(product) AS lowercase,
    UPPER(product) AS uppercase
FROM Orders
LIMIT 10;

-- ============================================
-- 8. Subqueries
-- ============================================

-- Subquery in WHERE
SELECT * FROM Orders
WHERE amount > (
    SELECT AVG(amount) FROM Orders
)
LIMIT 10;

-- ============================================
-- 9. DISTINCT
-- ============================================

-- Get unique values
SELECT DISTINCT customer_id FROM Orders LIMIT 10;

-- Count distinct
SELECT COUNT(DISTINCT customer_id) AS unique_customers FROM Orders;

-- ============================================
-- 10. LIMIT and OFFSET
-- ============================================

-- First 5 rows
SELECT * FROM Orders LIMIT 5;

-- ============================================
-- Cleanup
-- ============================================

-- Drop table when done
-- DROP TABLE Orders;

-- ============================================
-- Next Steps
-- ============================================
-- Try:
-- 1. kafka_integration.sql - Connect to Kafka topics
-- 2. window_aggregations.sql - Time-based windowing
-- 3. joins.sql - Join multiple streams
