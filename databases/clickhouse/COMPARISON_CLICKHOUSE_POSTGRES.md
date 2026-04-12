# ClickHouse vs PostgreSQL 18.3: Performance Comparison (Docker Compose)

This comparison demonstrates the performance difference between ClickHouse and PostgreSQL 18.3 for typical analytical workloads, using both in Docker containers with default configuration, as defined in the same docker-compose.yaml.

## Test Environment
- **Both databases running in Docker containers**
- **Default configuration** (no manual tuning)
- **Identical hardware, network, and isolation**

## Table Structure

### PostgreSQL
```sql
CREATE TABLE events (
    user_id INT,
    event TEXT,
    value FLOAT,
    data TIMESTAMP
);
CREATE INDEX idx_user_id ON events(user_id);
```

### ClickHouse
```sql
CREATE TABLE events (
    user_id UInt32,
    event String,
    value Float32,
    data DateTime
) ENGINE = MergeTree()
ORDER BY (user_id, data);
```

## Data Insertion (20 million rows)

### PostgreSQL
```sql
INSERT INTO events
SELECT
    (random() * 10000)::int,
    'click',
    random() * 100,
    NOW() - (random() * interval '1 day')
FROM generate_series(1, 20000000);
```
- **Time:** 42s

### ClickHouse
```sql
INSERT INTO events
SELECT
    rand() % 10000,
    'click',
    rand() % 100,
    now() - rand() % 100000
FROM numbers(20000000);
```
- **Time:** 2.6s

## Row Count

### PostgreSQL
```sql
select count(1) from events;
```
- **Time:** 0.59s
- **Result:** 20,000,000

### ClickHouse
```sql
select count(1) from events;
```
- **Time:** 0.003s
- **Result:** 20,000,000

## Analytical Query: Top Users
Query: returns the 10 users with the most events, showing the total events and the average value.

```sql
SELECT
    user_id,
    count(*) as total,
    avg(value)
FROM events
GROUP BY user_id
ORDER BY total DESC
LIMIT 10;
```

### PostgreSQL
- **Time:** 2.7s
- **Sample result:**
```
user_id | total | avg(value)
------- | ----- | ----------
662     | 2157  | 49.49
8501    | 2151  | 50.56
...     | ...   | ...
```

### ClickHouse
- **Time:** 0.035s
- **Sample result:**
```
user_id | total | avg(value)
------- | ----- | ----------
8404    | 2179  | 4.0
3813    | 2179  | 13.0
...     | ...   | ...
```

## Comparison Summary
- **Bulk insert:** ClickHouse is ~16x faster.
- **Row count:** ClickHouse is ~200x faster.
- **Analytical query (GROUP BY, ORDER BY, LIMIT):** ClickHouse is ~77x faster.
