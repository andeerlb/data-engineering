# PostgreSQL Basics

## What is PostgreSQL?

PostgreSQL (a.k.a. Postgres) is an open-source, object-relational database management system (RDBMS). It is ACID-compliant, highly extensible, and supports advanced SQL features like window functions, CTEs, full-text search, JSON/JSONB, and custom data types.

---

## Running PostgreSQL with Docker

```bash
docker compose up -d
```

Connect via `psql` inside the container:

```bash
docker exec -it postgres psql -U postgres -d mydb
```

Or connect from your host (requires `psql` installed locally):

```bash
psql -h localhost -p 5432 -U postgres -d mydb
```

---

## Core Concepts

### Databases and Schemas

| Concept  | Description |
|----------|-------------|
| Database | Top-level container; a server can hold many databases |
| Schema   | Namespace inside a database (default: `public`) |
| Table    | Stores rows of data within a schema |

```sql
CREATE DATABASE mydb;
CREATE SCHEMA analytics;
```

### Data Types

| Category | Common Types |
|----------|-------------|
| Numeric  | `INTEGER`, `BIGINT`, `NUMERIC(p,s)`, `REAL`, `DOUBLE PRECISION` |
| Text     | `VARCHAR(n)`, `TEXT`, `CHAR(n)` |
| Boolean  | `BOOLEAN` |
| Date/Time| `DATE`, `TIME`, `TIMESTAMP`, `TIMESTAMPTZ`, `INTERVAL` |
| JSON     | `JSON`, `JSONB` (binary, indexable — prefer JSONB) |
| UUID     | `UUID` |
| Array    | `INTEGER[]`, `TEXT[]`, etc. |

### Tables

```sql
CREATE TABLE users (
    id         SERIAL PRIMARY KEY,
    email      TEXT NOT NULL UNIQUE,
    name       VARCHAR(100),
    created_at TIMESTAMPTZ DEFAULT NOW()
);
```

`SERIAL` is shorthand for an auto-incrementing integer. For new code, prefer `GENERATED ALWAYS AS IDENTITY`.


## Indexes

```sql
-- B-tree (default) — good for equality and range queries
CREATE INDEX idx_users_email ON users (email);

-- Partial index — only indexes rows matching a condition
CREATE INDEX idx_active_users ON users (email) WHERE active = true;

-- Composite index
CREATE INDEX idx_orders_user_date ON orders (user_id, created_at DESC);
```

PostgreSQL automatically creates an index for `PRIMARY KEY` and `UNIQUE` constraints.

## Window Functions

Window functions compute values across a set of rows related to the current row without collapsing them into a single output row.

```sql
SELECT
    user_id,
    order_date,
    total,
    SUM(total)   OVER (PARTITION BY user_id ORDER BY order_date) AS running_total,
    ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY order_date) AS rn
FROM orders;
```

## CTEs (Common Table Expressions)

```sql
WITH ranked_orders AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY created_at DESC) AS rn
    FROM orders
)
SELECT * FROM ranked_orders WHERE rn = 1;
```

---

## Transactions

```sql
BEGIN;
    UPDATE accounts SET balance = balance - 100 WHERE id = 1;
    UPDATE accounts SET balance = balance + 100 WHERE id = 2;
COMMIT;
-- or ROLLBACK; to undo
```

PostgreSQL is fully ACID-compliant. Every statement runs inside a transaction by default.

## EXPLAIN / EXPLAIN ANALYZE

Use these to understand and optimize query performance.

```sql
EXPLAIN ANALYZE SELECT * FROM users WHERE email = 'alice@example.com';
```

Key terms in query plans:

| Term | Meaning |
|------|---------|
| `Seq Scan` | Full table scan — no index used |
| `Index Scan` | Uses an index to find rows |
| `Bitmap Heap Scan` | Bulk index lookup + heap fetch |
| `Hash Join` / `Nested Loop` | Join strategies |
| `cost=X..Y` | Estimated startup cost .. total cost |
| `actual time=X..Y` | Real execution time in ms |

## Key Configuration Files

| File | Purpose |
|------|---------|
| `postgresql.conf` | Server tuning (memory, connections, WAL, etc.) |
| `pg_hba.conf` | Client authentication rules |
| `pg_ident.conf` | OS user / DB user mapping |