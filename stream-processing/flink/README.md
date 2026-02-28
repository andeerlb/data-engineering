# Apache Flink

Apache Flink is a powerful and scalable distributed stream processing platform.

## Architecture

The setup includes:
- **JobManager**: Coordinates Flink job execution
- **TaskManager**: Executes Flink tasks
- **Kafka Integration**: Uses Kafka from `../kafka` folder via shared network

> **For details about Kafka integration, see [KAFKA_INTEGRATION.md](KAFKA_INTEGRATION.md)**

## Starting the Environment

### Option 1: Flink Only (without Kafka)

```bash
docker-compose up -d
```

### Option 2: Flink + Kafka (Recommended)

```bash
# 1. First, start Kafka (from ../kafka folder)
cd ../kafka
docker-compose up -d
cd ../flink

# 2. Then start Flink (which will connect to Kafka)
docker-compose up -d
```

**Important**: Flink automatically connects to Kafka's network when both are running.

## Access Web Interface

- **Flink Dashboard**: http://localhost:8081
  - Visualize jobs, taskmanagers, metrics, and logs

## Submit a Job

```bash
# Run example job (WordCount)
docker exec -it flink-jobmanager flink run /opt/flink/examples/streaming/WordCount.jar

# Submit custom job
docker exec -it flink-jobmanager flink run /opt/flink/jobs/your-job.jar

# Submit with specific parallelism, which means the job will run with 4 parallel instances (subtasks) where resources allow
docker exec -it flink-jobmanager flink run -p 4 /opt/flink/jobs/your-job.jar
```

## Usage Examples

### 1. WordCount (Basic)

```bash
# Run Flink's built-in example
docker exec -it flink-jobmanager flink run /opt/flink/examples/streaming/WordCount.jar
```

### 2. Kafka Integration

Flink is already configured to connect to Kafka from the `../kafka` folder.

**Prerequisite**: Kafka must be running:
```bash
cd ../kafka && docker-compose up -d && cd ../flink
```

Create a Kafka topic:
```bash
docker exec -it kafka kafka-topics --create \
  --topic input-topic \
  --bootstrap-server localhost:9092 \
  --partitions 1 \
  --replication-factor 1
```

**Note**: Use `kafka:29092` inside Flink jobs to connect to Kafka.

### 3. Flink SQL Client

```bash
# Enter SQL Client
docker exec -it flink-jobmanager /opt/flink/bin/sql-client.sh

# SQL Commands
SHOW TABLES;
SHOW FUNCTIONS;
```

## Examples

This repository includes comprehensive examples in multiple languages:

### Python Examples (`examples/py/`)
- **word_count.py**: Basic word count with DataStream API
- **kafka_consumer.py**: Read and process Kafka messages
- **kafka_to_kafka.py**: Complete ETL pipeline (Kafka → Transform → Kafka)

See [examples/py/README.md](examples/py/README.md) for setup and usage.

### Java Examples (`examples/java/`)
- **WordCount.java**: Basic transformations and aggregations
- **KafkaSourceExample.java**: Consume from Kafka topics
- **WindowAggregation.java**: Time-based window operations
- **KafkaToKafka.java**: Full pipeline with JSON processing

See [examples/java/README.md](examples/java/README.md) for setup and usage.

### SQL Examples (`examples/sql/`)
- **basics.sql**: Fundamentals (SELECT, WHERE, GROUP BY, functions)
- **kafka_integration.sql**: Reading/writing Kafka with various formats
- **window_aggregations.sql**: Tumble, Hop, Session windows
- **joins.sql**: Stream joins, temporal joins, lookup joins
- **advanced.sql**: Pattern matching, Top-N, deduplication, UDFs

See [examples/sql/README.md](examples/sql/README.md) for usage.

**Quick Access**: Check [examples/README.md](examples/README.md) for a complete overview.

## Useful Commands

```bash
# List running jobs
docker exec -it flink-jobmanager flink list

# Cancel a job
docker exec -it flink-jobmanager flink cancel <job-id>

# View JobManager logs
docker logs -f flink-jobmanager

# View TaskManager logs
docker logs -f flink-taskmanager

# Scale TaskManagers
docker-compose up -d --scale taskmanager=3
```

## Configuration

### Increase Task Slots

Edit `taskmanager.numberOfTaskSlots` in docker-compose.yaml:

```yaml
environment:
  - |
    FLINK_PROPERTIES=
    jobmanager.rpc.address: jobmanager
    taskmanager.numberOfTaskSlots: 4  # Increase here
```

### TaskManager Memory

```yaml
taskmanager:
  environment:
    - FLINK_PROPERTIES=...
    - JVM_ARGS=-Xms1024m -Xmx2048m
```

## Stop the Environment

```bash
# Stop containers
docker-compose down

# Stop and remove volumes (WARNING: deletes data)
docker-compose down -v
```

## Additional Resources

- [Official Flink Documentation](https://flink.apache.org/)
- [Flink Connectors](https://nightlies.apache.org/flink/flink-docs-stable/docs/connectors/datastream/overview/)
- [Flink SQL](https://nightlies.apache.org/flink/flink-docs-stable/docs/dev/table/sql/overview/)
- [PyFlink - Flink Python API](https://nightlies.apache.org/flink/flink-docs-stable/docs/dev/python/overview/)
- **[Flink + Kafka Integration Guide](KAFKA_INTEGRATION.md)** ⭐