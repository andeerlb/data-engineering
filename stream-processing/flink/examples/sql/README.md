# Apache Flink - SQL Examples

Examples using Flink Table API & SQL for stream processing.

## Prerequisites

- Flink cluster running (JobManager + TaskManager)
- For Kafka examples: Kafka must be running

## Getting Started

### Start SQL Client

```bash
# Enter SQL Client
docker exec -it flink-jobmanager /opt/flink/bin/sql-client.sh
```

### Run SQL Files

```bash
# Copy SQL file to container
docker cp basics.sql flink-jobmanager:/opt/flink/examples/

# Run from SQL Client
Flink SQL> SOURCE '/opt/flink/examples/basics.sql';
```

Or copy-paste the SQL commands directly into the SQL Client.

## Available Examples

### 1. basics.sql
Introduction to Flink SQL:
- Creating tables
- Simple queries
- Filters and transformations
- Aggregations

**Topics covered**:
- `CREATE TABLE`
- `SELECT`, `WHERE`, `GROUP BY`
- Built-in functions
- Views

### 2. kafka_integration.sql
Kafka connector examples:
- Reading from Kafka topics
- Writing to Kafka topics
- JSON format handling
- Continuous queries

**Prerequisites**: 
- Kafka running
- Topics created

**Create topics**:
```bash
docker exec -it kafka kafka-topics --create \
  --topic events-in --bootstrap-server localhost:9092 \
  --partitions 3 --replication-factor 1

docker exec -it kafka kafka-topics --create \
  --topic events-out --bootstrap-server localhost:9092 \
  --partitions 3 --replication-factor 1
```

### 3. window_aggregations.sql
Time-based windowing:
- Tumbling windows
- Hopping windows
- Session windows
- Window aggregations

**Topics covered**:
- `TUMBLE` function
- `HOP` function
- `SESSION` function
- Time attributes

### 4. joins.sql
Stream joins:
- Regular joins
- Interval joins
- Temporal joins
- Lookup joins

**Topics covered**:
- `INNER JOIN`
- `LEFT JOIN`
- Time-bounded joins
- Temporal tables

### 5. advanced.sql
Advanced features:
- User-defined functions
- MATCH_RECOGNIZE (pattern matching)
- Top-N queries
- Deduplication

## Common Commands

### Table Operations
```sql
-- List all tables
SHOW TABLES;

-- Describe table structure
DESCRIBE table_name;

-- Show table creation DDL
SHOW CREATE TABLE table_name;

-- Drop table
DROP TABLE table_name;
```

### Catalog Operations
```sql
-- Show catalogs
SHOW CATALOGS;

-- Show databases
SHOW DATABASES;

-- Use database
USE database_name;

-- Show functions
SHOW FUNCTIONS;
```

### Query Operations
```sql
-- Execute query (prints to console)
SELECT * FROM table_name;

-- Create view from query
CREATE VIEW my_view AS
SELECT * FROM table_name WHERE condition;

-- Insert into table
INSERT INTO sink_table
SELECT * FROM source_table;
```

### Configuration
```sql
-- Set execution mode
SET 'execution.runtime-mode' = 'streaming'; -- or 'batch'

-- Set parallelism
SET 'parallelism.default' = '4';

-- Set checkpoint interval
SET 'execution.checkpointing.interval' = '60s';
```

## SQL Client Tips

### Execute Multiple Statements
```sql
-- Separate statements with semicolon
CREATE TABLE table1 (...);
CREATE TABLE table2 (...);
INSERT INTO table2 SELECT * FROM table1;
```

### Load From File
```sql
-- SOURCE command
SOURCE '/path/to/file.sql';
```

### View Results
```sql
-- Table mode (default)
SET 'sql-client.execution.result-mode' = 'table';

-- Changelog mode (shows +/- for changes)
SET 'sql-client.execution.result-mode' = 'changelog';

-- Tableau mode (shows all changes)
SET 'sql-client.execution.result-mode' = 'tableau';
```

### Cancel Query
```
Ctrl + C (in SQL Client)
```

## Example Workflow

### 1. Create Source Table (from Kafka)
```sql
CREATE TABLE user_events (
    user_id STRING,
    event_type STRING,
    event_time TIMESTAMP(3),
    WATERMARK FOR event_time AS event_time - INTERVAL '5' SECOND
) WITH (
    'connector' = 'kafka',
    'topic' = 'events-in',
    'properties.bootstrap.servers' = 'kafka:29092',
    'properties.group.id' = 'flink-sql-consumer',
    'scan.startup.mode' = 'earliest-offset',
    'format' = 'json'
);
```

### 2. Create Sink Table (to Kafka)
```sql
CREATE TABLE event_counts (
    user_id STRING,
    event_count BIGINT,
    window_start TIMESTAMP(3),
    window_end TIMESTAMP(3),
    PRIMARY KEY (user_id, window_start) NOT ENFORCED
) WITH (
    'connector' = 'kafka',
    'topic' = 'events-out',
    'properties.bootstrap.servers' = 'kafka:29092',
    'format' = 'json'
);
```

### 3. Query and Process
```sql
INSERT INTO event_counts
SELECT 
    user_id,
    COUNT(*) as event_count,
    TUMBLE_START(event_time, INTERVAL '1' MINUTE) as window_start,
    TUMBLE_END(event_time, INTERVAL '1' MINUTE) as window_end
FROM user_events
GROUP BY 
    user_id,
    TUMBLE(event_time, INTERVAL '1' MINUTE);
```

### 4. Monitor Results
```bash
# In another terminal, consume from output topic
docker exec -it kafka kafka-console-consumer \
  --topic events-out \
  --bootstrap-server localhost:9092 \
  --from-beginning
```

## Data Types

Common Flink SQL data types:
- `STRING` - Text
- `INT`, `BIGINT` - Integers
- `FLOAT`, `DOUBLE` - Decimals
- `BOOLEAN` - True/False
- `TIMESTAMP(3)` - Timestamp with milliseconds
- `ARRAY<T>` - Array of type T
- `MAP<K, V>` - Map from K to V
- `ROW<...>` - Structured row type

## Time Attributes

### Processing Time
```sql
CREATE TABLE my_table (
    ...,
    proc_time AS PROCTIME()
) WITH (...);
```

### Event Time
```sql
CREATE TABLE my_table (
    ...,
    event_time TIMESTAMP(3),
    WATERMARK FOR event_time AS event_time - INTERVAL '5' SECOND
) WITH (...);
```