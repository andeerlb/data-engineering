# Apache Flink - Java Examples

Java examples using Flink DataStream API.

## Prerequisites

- Java 11 or higher
- Maven 3.6 or higher
- Docker (for running in Flink cluster)

## Building the Project

```bash
# Clean and package
mvn clean package

# The JAR will be in target/flink-examples-1.0-SNAPSHOT.jar
```

## Available Examples

### 1. WordCount.java
Basic word count example demonstrating:
- Reading from a collection
- FlatMap transformation
- Grouping and aggregation
- Output to console

**Run**:
```bash
mvn clean package
docker cp target/flink-examples-1.0-SNAPSHOT.jar flink-jobmanager:/opt/flink/jobs/
docker exec -it flink-jobmanager flink run \
  --class com.example.flink.WordCount \
  /opt/flink/jobs/flink-examples-1.0-SNAPSHOT.jar
```

### 2. KafkaSourceExample.java
Kafka integration example demonstrating:
- Kafka source connector
- Deserialization
- Event processing
- Output to console

**Prerequisites**: Kafka must be running
```bash
cd ../../kafka && docker-compose up -d
```

**Create topic**:
```bash
docker exec -it kafka kafka-topics --create \
  --topic input-events \
  --bootstrap-server localhost:9092 \
  --partitions 3 --replication-factor 1
```

**Run**:
```bash
docker exec -it flink-jobmanager flink run \
  --class com.example.flink.KafkaSourceExample \
  /opt/flink/jobs/flink-examples-1.0-SNAPSHOT.jar
```

### 3. WindowAggregation.java
Windowing example demonstrating:
- Tumbling windows
- Event time processing
- Aggregations
- Window functions

**Run**:
```bash
docker exec -it flink-jobmanager flink run \
  --class com.example.flink.WindowAggregation \
  /opt/flink/jobs/flink-examples-1.0-SNAPSHOT.jar
```

### 4. KafkaToKafka.java
Complete pipeline demonstrating:
- Kafka source
- Stream transformation
- Kafka sink
- End-to-end processing

**Create topics**:
```bash
docker exec -it kafka kafka-topics --create \
  --topic source-topic --bootstrap-server localhost:9092 \
  --partitions 3 --replication-factor 1

docker exec -it kafka kafka-topics --create \
  --topic sink-topic --bootstrap-server localhost:9092 \
  --partitions 3 --replication-factor 1
```

**Run**:
```bash
docker exec -it flink-jobmanager flink run \
  --class com.example.flink.KafkaToKafka \
  /opt/flink/jobs/flink-examples-1.0-SNAPSHOT.jar
```

**Test**:
```bash
# Producer
docker exec -it kafka kafka-console-producer \
  --topic source-topic --bootstrap-server localhost:9092

# Consumer
docker exec -it kafka kafka-console-consumer \
  --topic sink-topic --bootstrap-server localhost:9092 \
  --from-beginning
```

## Project Structure

```
java/
├── README.md
├── pom.xml
└── src/
    └── main/
        └── java/
            └── com/
                └── example/
                    └── flink/
                        ├── WordCount.java
                        ├── KafkaSourceExample.java
                        ├── WindowAggregation.java
                        └── KafkaToKafka.java
```

## Key Concepts

### DataStream API
The main abstraction for stream processing in Flink:
- **Source**: Where data comes from
- **Transformation**: Operations on data (map, filter, keyBy, etc.)
- **Sink**: Where data goes

### Common Transformations
- `map()` - 1-to-1 transformation
- `flatMap()` - 1-to-N transformation
- `filter()` - Conditional filtering
- `keyBy()` - Partition by key
- `reduce()` / `aggregate()` - Aggregations
- `window()` - Time-based windows

### Time & Windows
- **Event Time**: Time when event occurred
- **Processing Time**: Time when processed by Flink
- **Tumbling Window**: Fixed-size, non-overlapping
- **Sliding Window**: Fixed-size, overlapping
- **Session Window**: Dynamic, gap-based

## Development Tips

### Local Testing
```bash
# Run locally (without cluster)
mvn exec:java -Dexec.mainClass="com.example.flink.WordCount"
```

### Debugging
Add to your code:
```java
env.setParallelism(1); // Easier debugging
dataStream.print(); // Print to console
```

### Performance
```java
env.setParallelism(4); // Increase parallelism
env.enableCheckpointing(60000); // Enable fault tolerance
```

## Useful Commands

```bash
# List running jobs
docker exec -it flink-jobmanager flink list

# Cancel a job
docker exec -it flink-jobmanager flink cancel <job-id>

# View logs
docker logs -f flink-taskmanager

# Enter container
docker exec -it flink-jobmanager bash
```

## Resources

- [DataStream API](https://nightlies.apache.org/flink/flink-docs-stable/docs/dev/datastream/overview/)
- [Flink Kafka Connector](https://nightlies.apache.org/flink/flink-docs-stable/docs/connectors/datastream/kafka/)
- [Event Time & Watermarks](https://nightlies.apache.org/flink/flink-docs-stable/docs/concepts/time/)
- [Windows](https://nightlies.apache.org/flink/flink-docs-stable/docs/dev/datastream/operators/windows/)
