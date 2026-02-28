# Apache Flink - Examples

This directory contains code examples for Apache Flink in multiple languages.

## Available Examples

### 🐍 Python (PyFlink)
**Location**: [`py/`](py/)

Basic examples using PyFlink DataStream API:
- Word count
- Kafka consumer
- Kafka to Kafka pipeline

See [py/README.md](py/README.md) for details.

### ☕ Java
**Location**: [`java/`](java/)

Java examples using Flink DataStream API:
- Word count
- Kafka source
- Windowed aggregations
- Custom functions

See [java/README.md](java/README.md) for details.

### 📊 Flink SQL
**Location**: [`sql/`](sql/)

SQL examples using Flink Table API & SQL:
- Table creation from Kafka
- Streaming queries
- Window aggregations
- Joins

See [sql/README.md](sql/README.md) for details.

## Quick Start

### Python
```bash
cd py/
pip install -r requirements.txt
python word_count.py
```

### Java
```bash
cd java/
mvn clean package
docker cp target/flink-examples-*.jar flink-jobmanager:/opt/flink/jobs/
docker exec -it flink-jobmanager flink run /opt/flink/jobs/flink-examples-*.jar
```

### Flink SQL
```bash
# Start SQL Client
docker exec -it flink-jobmanager /opt/flink/bin/sql-client.sh

# Run queries from sql/ folder
```

## Project Structure

```
examples/
├── README.md          # This file
├── py/                # Python examples
│   ├── README.md
│   ├── word_count.py
│   ├── kafka_consumer.py
│   ├── kafka_to_kafka.py
│   └── requirements.txt
├── java/              # Java examples
│   ├── README.md
│   ├── pom.xml
│   ├── .gitignore
│   └── src/main/java/com/example/flink/
│       ├── WordCount.java
│       ├── KafkaSourceExample.java
│       ├── WindowAggregation.java
│       └── KafkaToKafka.java
└── sql/               # Flink SQL examples
    ├── README.md
    ├── basics.sql                    # SQL fundamentals
    ├── kafka_integration.sql         # Kafka connectors
    ├── window_aggregations.sql       # Time-based windows
    ├── joins.sql                     # Stream and table joins
    └── advanced.sql                  # Advanced features
```

## Prerequisites

### For Python Examples
- Python 3.7+
- apache-flink library

### For Java Examples
- Java 11+
- Maven 3.6+

### For SQL Examples
- Flink cluster running (JobManager + TaskManager)
- Kafka running (for Kafka integration examples)

## Resources

- [PyFlink Documentation](https://nightlies.apache.org/flink/flink-docs-stable/docs/dev/python/overview/)
- [DataStream API (Java)](https://nightlies.apache.org/flink/flink-docs-stable/docs/dev/datastream/overview/)
- [Table API & SQL](https://nightlies.apache.org/flink/flink-docs-stable/docs/dev/table/overview/)
- [Flink Training](https://nightlies.apache.org/flink/flink-docs-stable/docs/learn-flink/overview/)
