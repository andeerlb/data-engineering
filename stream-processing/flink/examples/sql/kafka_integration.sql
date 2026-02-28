-- ============================================
-- Flink SQL Kafka Integration
-- ============================================
-- Examples of reading from and writing to Kafka
-- Requires Kafka running (see ../../../kafka/docker-compose.yaml)

-- ============================================
-- Prerequisites
-- ============================================
-- 1. Start Kafka:
--    cd ../../../kafka && docker-compose up -d
-- 2. Create test topics:
--    docker exec -it kafka-kafka-1 kafka-topics --create --topic input-events --bootstrap-server localhost:9092 --partitions 3 --replication-factor 1
--    docker exec -it kafka-kafka-1 kafka-topics --create --topic output-results --bootstrap-server localhost:9092 --partitions 3 --replication-factor 1

-- ============================================
-- 1. Reading from Kafka (JSON Format)
-- ============================================

-- Create table that reads from Kafka
CREATE TABLE kafka_input (
    event_id STRING,
    user_id STRING,
    event_type STRING,
    event_value DOUBLE,
    event_time TIMESTAMP(3),
    WATERMARK FOR event_time AS event_time - INTERVAL '5' SECOND
) WITH (
    'connector' = 'kafka',
    'topic' = 'input-events',
    'properties.bootstrap.servers' = 'kafka:29092',
    'properties.group.id' = 'flink-consumer-group',
    'scan.startup.mode' = 'earliest-offset',
    'format' = 'json',
    'json.fail-on-missing-field' = 'false',
    'json.ignore-parse-errors' = 'true'
);

-- Query Kafka data
SELECT * FROM kafka_input LIMIT 10;

-- Filter events
SELECT * FROM kafka_input
WHERE event_type = 'click'
LIMIT 10;

-- ============================================
-- 2. Writing to Kafka (JSON Format)
-- ============================================

-- Create output table
CREATE TABLE kafka_output (
    user_id STRING,
    event_type STRING,
    event_count BIGINT,
    total_value DOUBLE,
    window_start TIMESTAMP(3),
    window_end TIMESTAMP(3)
) WITH (
    'connector' = 'kafka',
    'topic' = 'output-results',
    'properties.bootstrap.servers' = 'kafka:29092',
    'format' = 'json',
    'json.encode.decimal-as-plain-number' = 'true'
);

-- ============================================
-- 3. Simple ETL Pipeline (Kafka to Kafka)
-- ============================================

-- Transform and write to output topic
INSERT INTO kafka_output
SELECT 
    user_id,
    event_type,
    COUNT(*) AS event_count,
    SUM(event_value) AS total_value,
    TUMBLE_START(event_time, INTERVAL '1' MINUTE) AS window_start,
    TUMBLE_END(event_time, INTERVAL '1' MINUTE) AS window_end
FROM kafka_input
GROUP BY 
    user_id,
    event_type,
    TUMBLE(event_time, INTERVAL '1' MINUTE);

-- ============================================
-- 4. CSV Format (Alternative)
-- ============================================

-- Create CSV input table
CREATE TABLE kafka_csv_input (
    id STRING,
    name STRING,
    value DOUBLE,
    timestamp_str STRING
) WITH (
    'connector' = 'kafka',
    'topic' = 'csv-input',
    'properties.bootstrap.servers' = 'kafka:29092',
    'scan.startup.mode' = 'earliest-offset',
    'format' = 'csv',
    'csv.field-delimiter' = ',',
    'csv.ignore-parse-errors' = 'true'
);

-- ============================================
-- 5. Avro Format (with Schema Registry)
-- ============================================

-- Note: Requires Confluent Schema Registry
-- Uncomment when Schema Registry is available

/*
CREATE TABLE kafka_avro_input (
    id STRING,
    name STRING,
    value DOUBLE,
    event_time TIMESTAMP(3)
) WITH (
    'connector' = 'kafka',
    'topic' = 'avro-events',
    'properties.bootstrap.servers' = 'kafka:29092',
    'scan.startup.mode' = 'earliest-offset',
    'format' = 'avro-confluent',
    'avro-confluent.url' = 'http://schema-registry:8081'
);
*/

-- ============================================
-- 6. Multiple Kafka Topics Pattern
-- ============================================

-- Read from multiple topics with pattern
CREATE TABLE multi_topic_input (
    event_id STRING,
    data STRING,
    event_time TIMESTAMP(3),
    WATERMARK FOR event_time AS event_time - INTERVAL '5' SECOND
) WITH (
    'connector' = 'kafka',
    'topic-pattern' = 'events-.*',  -- matches events-users, events-orders, etc.
    'properties.bootstrap.servers' = 'kafka:29092',
    'scan.startup.mode' = 'earliest-offset',
    'format' = 'json'
);

-- ============================================
-- 7. Upsert Kafka (Changelog Stream)
-- ============================================

-- Create upsert kafka table (for updates)
CREATE TABLE user_profiles (
    user_id STRING,
    username STRING,
    email STRING,
    last_updated TIMESTAMP(3),
    PRIMARY KEY (user_id) NOT ENFORCED
) WITH (
    'connector' = 'upsert-kafka',
    'topic' = 'user-profiles',
    'properties.bootstrap.servers' = 'kafka:29092',
    'key.format' = 'json',
    'value.format' = 'json'
);

-- Insert/Update user
INSERT INTO user_profiles VALUES
    ('user1', 'john_doe', 'john@example.com', CURRENT_TIMESTAMP),
    ('user2', 'jane_smith', 'jane@example.com', CURRENT_TIMESTAMP);

-- Query current state
SELECT * FROM user_profiles;

-- ============================================
-- 8. Partitioned Output
-- ============================================

-- Write to Kafka with specific partition key
CREATE TABLE partitioned_output (
    partition_key STRING,
    event_data STRING,
    event_count BIGINT
) WITH (
    'connector' = 'kafka',
    'topic' = 'partitioned-results',
    'properties.bootstrap.servers' = 'kafka:29092',
    'format' = 'json',
    'sink.partitioner' = 'fixed'  -- or 'round-robin'
);

-- ============================================
-- 9. Exactly-Once Semantics
-- ============================================

-- Enable exactly-once with Kafka sink
CREATE TABLE exactly_once_output (
    id STRING,
    result DOUBLE
) WITH (
    'connector' = 'kafka',
    'topic' = 'exactly-once-topic',
    'properties.bootstrap.servers' = 'kafka:29092',
    'format' = 'json',
    'sink.delivery-guarantee' = 'exactly-once',  -- or 'at-least-once', 'none'
    'sink.transactional-id-prefix' = 'flink-txn'
);

-- ============================================
-- 10. Debugging Kafka Data
-- ============================================

-- Create print sink for testing
CREATE TABLE print_sink (
    event_id STRING,
    event_data STRING
) WITH (
    'connector' = 'print'
);

-- Copy data to console for debugging
INSERT INTO print_sink
SELECT event_id, CAST(event_value AS STRING) AS event_data
FROM kafka_input
WHERE event_type = 'click';

-- ============================================
-- Testing with Kafka Console Producer
-- ============================================

-- In a terminal, produce test messages:
--
-- docker exec -it kafka-kafka-1 kafka-console-producer \
--   --topic input-events \
--   --bootstrap-server localhost:9092
--
-- Then paste JSON messages:
-- {"event_id":"1","user_id":"user1","event_type":"click","event_value":10.5,"event_time":"2024-01-01T10:00:00"}
-- {"event_id":"2","user_id":"user2","event_type":"view","event_value":5.0,"event_time":"2024-01-01T10:01:00"}
-- {"event_id":"3","user_id":"user1","event_type":"click","event_value":15.0,"event_time":"2024-01-01T10:02:00"}

-- ============================================
-- Consuming Results from Kafka
-- ============================================

-- Read results in terminal:
--
-- docker exec -it kafka-kafka-1 kafka-console-consumer \
--   --topic output-results \
--   --bootstrap-server localhost:9092 \
--   --from-beginning \
--   --property print.key=true

-- ============================================
-- Common Kafka Properties
-- ============================================

-- Additional Kafka consumer properties:
-- 'properties.group.id' = 'my-consumer-group'
-- 'properties.auto.offset.reset' = 'earliest'  -- or 'latest'
-- 'properties.enable.auto.commit' = 'true'
-- 'properties.max.poll.records' = '500'
-- 'properties.session.timeout.ms' = '10000'

-- Additional Kafka producer properties:
-- 'properties.compression.type' = 'snappy'  -- or 'gzip', 'lz4', 'zstd'
-- 'properties.linger.ms' = '10'
-- 'properties.batch.size' = '16384'
-- 'properties.acks' = 'all'  -- or '0', '1'

-- ============================================
-- Cleanup
-- ============================================

-- Drop tables
-- DROP TABLE kafka_input;
-- DROP TABLE kafka_output;
-- DROP TABLE kafka_csv_input;
-- DROP TABLE multi_topic_input;
-- DROP TABLE user_profiles;
-- DROP TABLE partitioned_output;
-- DROP TABLE exactly_once_output;
-- DROP TABLE print_sink;

-- ============================================
-- Next Steps
-- ============================================
-- Try:
-- 1. window_aggregations.sql - Time-based windowing
-- 2. joins.sql - Join Kafka streams
-- 3. advanced.sql - Pattern matching and Top-N
