# ClickHouse Cluster with ZooKeeper (Docker Compose)
ClickHouse exists to solve problems where you need to analyze huge volumes of data very quickly—especially for analytics, reporting, and real-time dashboards.

A good use case for ClickHouse is when you have billions of rows (or more) and need to run complex analytical queries (like aggregations, filtering, group by, time series analysis) in seconds or less. It’s designed for OLAP (Online Analytical Processing), not for transactional workloads.

Typical scenarios:

Analytics platforms (web, app, or business analytics)
Real-time dashboards (monitoring, metrics, logs)
Event data (clickstreams, IoT, telemetry)
Data warehousing for fast reporting
ClickHouse is used by companies like Yandex, Cloudflare, and many others to power analytics on massive datasets, because it’s extremely fast for reading and aggregating data at scale. It’s column-oriented, which means it’s optimized for reading lots of data, not for frequent updates or deletes.

## Architecture Overview

This setup provides a distributed ClickHouse cluster using Docker Compose, with ZooKeeper as the coordination service. The architecture is as follows:

- **4 ClickHouse nodes** (`clickhouse-01`, `clickhouse-02`, `clickhouse-03`, `clickhouse-04`)
- **1 ZooKeeper node** (for cluster coordination)

Each ClickHouse node runs in its own container and communicates with ZooKeeper for replication, distributed DDL, and failover management. The cluster is suitable for development, testing, and learning distributed ClickHouse concepts.

## How It Works

- **ZooKeeper**: Handles coordination, metadata, and synchronization between ClickHouse nodes. Required for replicated tables and distributed queries.
- **ClickHouse nodes**: Each node is a full ClickHouse server, configured to use ZooKeeper for cluster operations. Nodes can be accessed individually for queries and management.

## Ports

- ClickHouse HTTP interface: 8123 (node 1), 8124 (node 2), 8125 (node 3), 8126 (node 4)
- ClickHouse native TCP: 9000 (node 1), 9001 (node 2), 9002 (node 3), 9003 (node 4)
- ZooKeeper: 2181

## Usage

### Starting the Cluster
```sh
docker compose up -d
```

### Stopping the Cluster
```sh
docker compose down
```

### Cleaning Orphan Containers
```sh
docker compose down --remove-orphans
```

## Web Interface (ClickHouse UI)

You can access the built-in ClickHouse Web UI at:
- [http://localhost:8123](http://localhost:8123) (node 1)
- [http://localhost:8124](http://localhost:8124) (node 2)
- [http://localhost:8125](http://localhost:8125) (node 3)
- [http://localhost:8126](http://localhost:8126) (node 4)

This interface allows you to run SQL queries and view results directly in your browser.

## Advanced Interfaces

### Tabix
- **Tabix** is a powerful open-source web UI for ClickHouse.
- To use Tabix, run it as a separate Docker container:
  ```sh
  docker run -d -p 8080:80 --name tabix --rm spoonest/clickhouse-tabix-web-client
  ```
- Access Tabix at [http://localhost:8080](http://localhost:8080)
- Connect to your ClickHouse node using host `host.docker.internal` (if Tabix is running outside the cluster) and port `8123`.

### DBeaver / DataGrip
- Both are desktop SQL clients with ClickHouse support.
- Add a new ClickHouse connection:
  - **Host**: `localhost`
  - **Port**: `8123` (HTTP) or `9000` (native TCP)
  - **User**: `default`
  - **Password**: (leave blank unless you set one)
- You can manage databases, run queries, and visualize data.

## Example: Creating a Replicated Table

This example demonstrates how to create a replicated table in a ClickHouse cluster using the ReplicatedMergeTree engine. This engine allows tables to be automatically replicated across multiple nodes for high availability and fault tolerance. ZooKeeper is used to coordinate replication and ensure consistency between replicas.

When you run the following command, ClickHouse will create the table on all nodes defined in the cluster, and each replica will use ZooKeeper to synchronize data:

```sql
CREATE TABLE default.replica_test ON CLUSTER 'cluster_2S_2R' (
  id UInt32
) ENGINE = ReplicatedMergeTree('/clickhouse/tables/{shard}/replica_test', '{replica}')
ORDER BY id;
```

**How it works:**
- `ON CLUSTER 'cluster_2S_2R'`: Executes the statement on all nodes in the cluster.
- `ReplicatedMergeTree(...)`: Tells ClickHouse to use the ReplicatedMergeTree engine, which replicates data between nodes.
- `'/clickhouse/tables/{shard}/replica_test'`: The ZooKeeper path for the table, where `{shard}` is replaced by the shard number for each node.
- `'{replica}'`: The replica identifier, replaced by the replica name for each node.
- `ORDER BY id`: Sets the primary key for the table.

This setup ensures that data inserted into the table is automatically replicated and kept consistent across the cluster, providing resilience against node failures and enabling distributed queries.

## Material
- https://www.youtube.com/watch?v=iLXXoDaFoxs
- https://www.youtube.com/watch?v=njjBdmAQnR0
- https://www.youtube.com/watch?v=2ryG3Jy6eIY
- https://clickhouse.com/docs