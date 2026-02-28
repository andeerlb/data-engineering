-- ============================================
-- Flink SQL Window Aggregations
-- ============================================
-- Time-based windowing for stream processing
-- Windows allow aggregating continuous streams into finite buckets

-- ============================================
-- Setup: Create Source Table
-- ============================================

-- Create a table with time-based data
CREATE TABLE sensor_readings (
    sensor_id STRING,
    temperature DOUBLE,
    humidity DOUBLE,
    location STRING,
    reading_time TIMESTAMP(3),
    WATERMARK FOR reading_time AS reading_time - INTERVAL '5' SECOND
) WITH (
    'connector' = 'datagen',
    'rows-per-second' = '10',
    'fields.sensor_id.length' = '5',
    'fields.temperature.min' = '15.0',
    'fields.temperature.max' = '35.0',
    'fields.humidity.min' = '30.0',
    'fields.humidity.max' = '90.0'
);

-- View raw data
SELECT * FROM sensor_readings LIMIT 10;

-- ============================================
-- 1. TUMBLE Windows (Fixed, Non-overlapping)
-- ============================================

-- 1-minute tumbling window
-- Windows: [00:00-01:00), [01:00-02:00), [02:00-03:00), ...
SELECT 
    sensor_id,
    TUMBLE_START(reading_time, INTERVAL '1' MINUTE) AS window_start,
    TUMBLE_END(reading_time, INTERVAL '1' MINUTE) AS window_end,
    COUNT(*) AS reading_count,
    AVG(temperature) AS avg_temp,
    MIN(temperature) AS min_temp,
    MAX(temperature) AS max_temp
FROM sensor_readings
GROUP BY 
    sensor_id,
    TUMBLE(reading_time, INTERVAL '1' MINUTE);

-- 5-minute tumbling window with filter
SELECT 
    location,
    TUMBLE_START(reading_time, INTERVAL '5' MINUTE) AS window_start,
    COUNT(*) AS reading_count,
    AVG(temperature) AS avg_temp,
    AVG(humidity) AS avg_humidity
FROM sensor_readings
GROUP BY 
    location,
    TUMBLE(reading_time, INTERVAL '5' MINUTE)
HAVING AVG(temperature) > 25.0;  -- Alert on high temperatures

-- ============================================
-- 2. HOP Windows (Sliding, Overlapping)
-- ============================================

-- 10-minute window, sliding every 5 minutes
-- Windows: [00:00-10:00), [05:00-15:00), [10:00-20:00), ...
SELECT 
    sensor_id,
    HOP_START(reading_time, INTERVAL '5' MINUTE, INTERVAL '10' MINUTE) AS window_start,
    HOP_END(reading_time, INTERVAL '5' MINUTE, INTERVAL '10' MINUTE) AS window_end,
    COUNT(*) AS reading_count,
    AVG(temperature) AS avg_temp
FROM sensor_readings
GROUP BY 
    sensor_id,
    HOP(reading_time, INTERVAL '5' MINUTE, INTERVAL '10' MINUTE);

-- 1-hour window, sliding every 15 minutes
SELECT 
    location,
    HOP_START(reading_time, INTERVAL '15' MINUTE, INTERVAL '1' HOUR) AS window_start,
    HOP_END(reading_time, INTERVAL '15' MINUTE, INTERVAL '1' HOUR) AS window_end,
    AVG(temperature) AS avg_temp,
    STDDEV(temperature) AS temp_stddev
FROM sensor_readings
GROUP BY 
    location,
    HOP(reading_time, INTERVAL '15' MINUTE, INTERVAL '1' HOUR);

-- ============================================
-- 3. SESSION Windows (Gap-based)
-- ============================================

-- Session window with 30-second inactivity gap
-- Groups events that occur within 30 seconds of each other
SELECT 
    sensor_id,
    SESSION_START(reading_time, INTERVAL '30' SECOND) AS session_start,
    SESSION_END(reading_time, INTERVAL '30' SECOND) AS session_end,
    COUNT(*) AS events_in_session,
    AVG(temperature) AS avg_temp
FROM sensor_readings
GROUP BY 
    sensor_id,
    SESSION(reading_time, INTERVAL '30' SECOND);

-- Session with 1-minute gap (longer inactivity threshold)
SELECT 
    location,
    SESSION_START(reading_time, INTERVAL '1' MINUTE) AS session_start,
    SESSION_END(reading_time, INTERVAL '1' MINUTE) AS session_end,
    COUNT(*) AS reading_count,
    MAX(temperature) AS max_temp
FROM sensor_readings
GROUP BY 
    location,
    SESSION(reading_time, INTERVAL '1' MINUTE);

-- ============================================
-- 4. Multiple Aggregations in Windows
-- ============================================

SELECT 
    sensor_id,
    TUMBLE_START(reading_time, INTERVAL '1' MINUTE) AS window_start,
    COUNT(*) AS reading_count,
    
    -- Temperature statistics
    AVG(temperature) AS avg_temp,
    MIN(temperature) AS min_temp,
    MAX(temperature) AS max_temp,
    STDDEV(temperature) AS temp_stddev,
    
    -- Humidity statistics
    AVG(humidity) AS avg_humidity,
    MIN(humidity) AS min_humidity,
    MAX(humidity) AS max_humidity,
    
    -- Derived metrics
    MAX(temperature) - MIN(temperature) AS temp_range
FROM sensor_readings
GROUP BY 
    sensor_id,
    TUMBLE(reading_time, INTERVAL '1' MINUTE);

-- ============================================
-- 5. Window TVF (Table-Valued Functions) - Alternative Syntax
-- ============================================

-- Tumbling window using TVF (recommended for newer Flink versions)
SELECT 
    sensor_id,
    window_start,
    window_end,
    COUNT(*) AS reading_count,
    AVG(temperature) AS avg_temp
FROM TABLE(
    TUMBLE(TABLE sensor_readings, DESCRIPTOR(reading_time), INTERVAL '1' MINUTE)
)
GROUP BY sensor_id, window_start, window_end;

-- Hopping window using TVF
SELECT 
    location,
    window_start,
    window_end,
    AVG(temperature) AS avg_temp
FROM TABLE(
    HOP(TABLE sensor_readings, DESCRIPTOR(reading_time), INTERVAL '5' MINUTE, INTERVAL '10' MINUTE)
)
GROUP BY location, window_start, window_end;

-- Cumulative window (from start of day to current time)
SELECT 
    sensor_id,
    window_start,
    window_end,
    COUNT(*) AS total_readings,
    AVG(temperature) AS cumulative_avg_temp
FROM TABLE(
    CUMULATE(TABLE sensor_readings, DESCRIPTOR(reading_time), INTERVAL '1' MINUTE, INTERVAL '1' HOUR)
)
GROUP BY sensor_id, window_start, window_end;

-- ============================================
-- 6. Window Offset
-- ============================================

-- Tumbling window with 30-second offset
-- Shifts windows by 30 seconds: [00:00:30-01:00:30), [01:00:30-02:00:30), ...
SELECT 
    sensor_id,
    TUMBLE_START(reading_time, INTERVAL '1' MINUTE, TIME '00:00:30') AS window_start,
    TUMBLE_END(reading_time, INTERVAL '1' MINUTE, TIME '00:00:30') AS window_end,
    COUNT(*) AS reading_count,
    AVG(temperature) AS avg_temp
FROM sensor_readings
GROUP BY 
    sensor_id,
    TUMBLE(reading_time, INTERVAL '1' MINUTE, TIME '00:00:30');

-- ============================================
-- 7. Window with Kafka Source
-- ============================================

-- Create Kafka source with event time
CREATE TABLE kafka_events (
    event_id STRING,
    event_type STRING,
    event_value DOUBLE,
    event_time TIMESTAMP(3),
    WATERMARK FOR event_time AS event_time - INTERVAL '5' SECOND
) WITH (
    'connector' = 'kafka',
    'topic' = 'events',
    'properties.bootstrap.servers' = 'kafka:29092',
    'scan.startup.mode' = 'earliest-offset',
    'format' = 'json'
);

-- Aggregate Kafka events in 1-minute windows
SELECT 
    event_type,
    TUMBLE_START(event_time, INTERVAL '1' MINUTE) AS window_start,
    TUMBLE_END(event_time, INTERVAL '1' MINUTE) AS window_end,
    COUNT(*) AS event_count,
    SUM(event_value) AS total_value,
    AVG(event_value) AS avg_value
FROM kafka_events
GROUP BY 
    event_type,
    TUMBLE(event_time, INTERVAL '1' MINUTE);

-- ============================================
-- 8. Window with Output to Kafka
-- ============================================

CREATE TABLE kafka_window_output (
    sensor_id STRING,
    window_start TIMESTAMP(3),
    window_end TIMESTAMP(3),
    reading_count BIGINT,
    avg_temp DOUBLE,
    max_temp DOUBLE
) WITH (
    'connector' = 'kafka',
    'topic' = 'sensor-aggregates',
    'properties.bootstrap.servers' = 'kafka:29092',
    'format' = 'json'
);

-- Continuous windowed aggregation to Kafka
INSERT INTO kafka_window_output
SELECT 
    sensor_id,
    TUMBLE_START(reading_time, INTERVAL '1' MINUTE) AS window_start,
    TUMBLE_END(reading_time, INTERVAL '1' MINUTE) AS window_end,
    COUNT(*) AS reading_count,
    AVG(temperature) AS avg_temp,
    MAX(temperature) AS max_temp
FROM sensor_readings
GROUP BY 
    sensor_id,
    TUMBLE(reading_time, INTERVAL '1' MINUTE);

-- ============================================
-- 9. Advanced Window Patterns
-- ============================================

-- Early firing (emit partial results before window closes)
-- Note: Requires configuration in job settings
SELECT 
    sensor_id,
    TUMBLE_START(reading_time, INTERVAL '1' MINUTE) AS window_start,
    COUNT(*) AS reading_count,
    AVG(temperature) AS avg_temp
FROM sensor_readings
GROUP BY 
    sensor_id,
    TUMBLE(reading_time, INTERVAL '1' MINUTE);

-- Window with OVER clause (for ranking within windows)
SELECT 
    sensor_id,
    reading_time,
    temperature,
    AVG(temperature) OVER (
        PARTITION BY sensor_id
        ORDER BY reading_time
        ROWS BETWEEN 10 PRECEDING AND CURRENT ROW
    ) AS moving_avg_temp
FROM sensor_readings;

-- ============================================
-- 10. Multiple Time Attributes
-- ============================================

-- Table with both event time and processing time
CREATE TABLE dual_time_events (
    event_id STRING,
    event_value DOUBLE,
    event_time TIMESTAMP(3),
    proc_time AS PROCTIME(),
    WATERMARK FOR event_time AS event_time - INTERVAL '5' SECOND
) WITH (
    'connector' = 'datagen',
    'rows-per-second' = '5'
);

-- Window on event time
SELECT 
    TUMBLE_START(event_time, INTERVAL '1' MINUTE) AS window_start,
    COUNT(*) AS event_count
FROM dual_time_events
GROUP BY TUMBLE(event_time, INTERVAL '1' MINUTE);

-- Window on processing time (less common, but useful for monitoring)
SELECT 
    TUMBLE_START(proc_time, INTERVAL '1' MINUTE) AS window_start,
    COUNT(*) AS event_count
FROM dual_time_events
GROUP BY TUMBLE(proc_time, INTERVAL '1' MINUTE);

-- ============================================
-- Window Size Examples
-- ============================================

-- Different window sizes for different use cases:
-- INTERVAL '10' SECOND   -- Real-time monitoring
-- INTERVAL '1' MINUTE    -- Recent trends
-- INTERVAL '5' MINUTE    -- Short-term analysis
-- INTERVAL '15' MINUTE   -- Medium-term patterns
-- INTERVAL '1' HOUR      -- Hourly reports
-- INTERVAL '1' DAY       -- Daily summaries

-- ============================================
-- Cleanup
-- ============================================

-- DROP TABLE sensor_readings;
-- DROP TABLE kafka_events;
-- DROP TABLE kafka_window_output;
-- DROP TABLE dual_time_events;

-- ============================================
-- Key Concepts
-- ============================================
-- 1. WATERMARK: Defines how late events can arrive
-- 2. Event Time: Time when event occurred (embedded in data)
-- 3. Processing Time: Time when Flink processes the event
-- 4. Window Types:
--    - TUMBLE: Fixed, non-overlapping windows
--    - HOP: Sliding windows with overlap
--    - SESSION: Dynamic windows based on activity gaps
--    - CUMULATE: Growing windows (useful for dashboards)

-- ============================================
-- Next Steps
-- ============================================
-- Try:
-- 1. joins.sql - Join streams and tables
-- 2. advanced.sql - Pattern matching and Top-N queries
