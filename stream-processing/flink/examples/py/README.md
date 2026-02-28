# Apache Flink - Examples

This directory contains code examples for Apache Flink.

## Prerequisites

```bash
pip install apache-flink
```

## Available Examples

### 1. word_count.py
Basic word count example using PyFlink.

### 2. kafka_consumer.py
Reads data from a Kafka topic and processes it with Flink.

### 3. kafka_to_kafka.py
Pipeline that reads from a Kafka topic, processes, and writes to another topic.

## How to Run

### Option 1: Local Python

```bash
# Install dependencies
pip install -r requirements.txt

# Run an example
python word_count.py
```

### Option 2: Inside Flink Container

```bash
# Copy example to container
docker cp word_count.py flink-jobmanager:/opt/flink/examples/

# Run inside container
docker exec -it flink-jobmanager python /opt/flink/examples/word_count.py
```

### Option 3: Submit as Job

```bash
# For more complex jobs, compile to JAR and submit
docker exec -it flink-jobmanager flink run /opt/flink/jobs/your-job.jar
```

## Flink Job Structure

```python
from pyflink.datastream import StreamExecutionEnvironment

# 1. Create execution environment
env = StreamExecutionEnvironment.get_execution_environment()

# 2. Create data stream
data_stream = env.from_collection([1, 2, 3, 4, 5])

# 3. Apply transformations
result = data_stream.map(lambda x: x * 2)

# 4. Define output (sink)
result.print()

# 5. Execute the job
env.execute("Job Name")
```

## Important Concepts

### DataStream API
- **Source**: Where data comes from (Kafka, file, collection, etc.)
- **Transformation**: Operations on data (map, filter, reduce, etc.)
- **Sink**: Where data goes (Kafka, file, database, etc.)

### Table API / SQL
SQL interface for processing streams as tables.

### Window Operations
Group data into time windows for aggregations.

## References

- [PyFlink Documentation](https://nightlies.apache.org/flink/flink-docs-stable/docs/dev/python/overview/)
- [DataStream API](https://nightlies.apache.org/flink/flink-docs-stable/docs/dev/datastream/overview/)
