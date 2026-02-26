# Apache Kafka with Docker Compose

Apache Kafka setup using Docker Compose, including Zookeeper, Kafka broker, Kafka UI, Schema Registry, and Kafka Connect.

## Overview

This setup provides a production-ready Apache Kafka environment with the following components:

- **Apache Kafka**: Distributed streaming platform that acts as a high-throughput, low-latency message broker. It stores streams of records in topics that can be replicated across multiple servers for fault tolerance. Producers publish messages to topics, and consumers read from them. Think of it as a real-time event distribution system that can handle millions of messages per second.

- **Zookeeper**: A coordination service that manages the Kafka cluster. It keeps track of which brokers are alive, maintains topic configurations, leader elections for partitions, and manages consumer group offsets. Without Zookeeper, Kafka wouldn't know how to organize itself in a clustered environment.

- **Kafka UI**: A modern web-based user interface that makes it easy to visualize and manage your Kafka cluster without using command-line tools. You can view topics, see messages in real-time, inspect consumer groups and their lag, create topics, and monitor broker health all from a beautiful dashboard.

- **Schema Registry**: A centralized repository for managing data schemas (using Avro, Protobuf, or JSON Schema). It ensures that producers and consumers agree on the structure of the data being transmitted, prevents incompatible changes, and enables schema versioning and evolution. This is essential for data quality and avoiding silent data corruption.

- **Kafka Connect**: A framework for connecting Kafka with external systems (databases, data warehouses, cloud storage, APIs, etc.). Instead of writing custom code, you can use pre-built connectors to import data into Kafka from sources or export Kafka data to sinks. It's perfect for building ETL/ELT pipelines without coding.

## Services

### Kafka Broker
- **Port**: 9092 (external), 29092 (internal)
- **JMX Port**: 9093
- **Bootstrap Server**: `localhost:9092`
- **Description**: The core component that stores and serves messages. This is the actual Kafka server that receives data from producers, stores it in partitions, and distributes it to consumers. In a production setup, you'd have multiple brokers working together. This single broker is configured for development and testing.
- **Key Features**:
  - Stores messages persistently on disk
  - Replicates data across partitions
  - Handles producer and consumer connections
  - Manages partition leadership and replication

### Zookeeper
- **Port**: 2181
- **Description**: The "conductor" of your Kafka orchestra. Zookeeper manages cluster metadata, tracks which brokers are available, stores partition leadership information, and manages consumer group offsets. Every broker and client must register with Zookeeper to operate correctly.
- **Responsibilities**:
  - Broker registration and discovery
  - Topic and partition configuration management
  - Leader election for partitions
  - Consumer group coordination
  - Configuration and state management
- **Note**: For production, Zookeeper is typically being phased out in favor of KRaft (Kafka Raft) mode, but it's still widely used and essential for traditional Kafka setups.

### Kafka UI
- **Port**: 8080
- **URL**: http://localhost:8080
- **Description**: A modern, user-friendly web interface developed by Provectus that eliminates the need for command-line tools. Instead of memorizing docker exec commands, you can use the web UI to manage your entire Kafka cluster visually.
- **Features**:
  - **Cluster Overview**: See broker status, storage, and resource usage
  - **Topics Management**: Create, delete, and configure topics
  - **Message Browser**: View actual message contents in real-time
  - **Consumer Groups**: Monitor lag, partition assignments, and offsets
  - **Configuration**: Edit topic configurations and parameters
  - **Metrics**: View performance and throughput statistics
  - **Search**: Find messages based on content or metadata
- **Use Case**: Perfect for debugging, monitoring, and ad-hoc cluster management.

### Schema Registry
- **Port**: 8081
- **URL**: http://localhost:8081
- **Description**: A centralized database for data schemas. It prevents chaos in your Kafka topics by enforcing that all messages conform to registered schemas. When a producer or consumer registers with Schema Registry, it ensures data quality and compatibility.
- **Benefits**:
  - **Data Validation**: Ensures messages match agreed-upon structure
  - **Schema Versioning**: Track multiple versions of the same schema
  - **Backward Compatibility**: Validate that new versions work with old consumers
  - **Forward Compatibility**: Ensure old consumers won't break with new messages
  - **Avro Support**: Efficient binary serialization with Avro format
  - **Type Safety**: Catch data type mismatches before they become problems
- **Example Use Case**: If you have a "user-events" topic, you register a schema that defines a user must have an id, email, and timestamp. Any producer sending data without these fields will be rejected.

### Kafka Connect
- **Port**: 8083
- **URL**: http://localhost:8083
- **Description**: A distributed framework for connecting Kafka to external systems through pre-built or custom connectors. Instead of writing applications to read/write data, you configure connectors that handle the integration automatically.
- **Connector Types**:
  - **Source Connectors**: Pull data FROM external systems INTO Kafka (databases, APIs, logs, files)
  - **Sink Connectors**: Push data FROM Kafka TO external systems (data warehouses, databases, cloud storage, dashboards)
- **Popular Connectors**:
  - JDBC Connector (PostgreSQL, MySQL, Oracle, SQL Server)
  - S3 Connector (AWS S3)
  - Elasticsearch Sink
  - JSON/Avro transformations
  - Many more from Confluent Hub
- **Advantages**:
  - No code needed - pure configuration
  - Automatic fault tolerance and scaling
  - Schema Registry integration
  - Monitoring and metrics built-in
  - Community and enterprise connectors available
- **Example Use Case**: You want to sync a PostgreSQL table to Kafka in real-time AND export all Kafka messages to S3 for data lake storage. With Kafka Connect, you configure two connectors and you're done.

## Usage

### Creating Topics

#### Using kafka-topics command:
```bash
docker exec -it kafka kafka-topics \
  --create \
  --topic my-topic \
  --bootstrap-server localhost:9092 \
  --partitions 3 \
  --replication-factor 1
```

#### List all topics:
```bash
docker exec -it kafka kafka-topics \
  --list \
  --bootstrap-server localhost:9092
```

#### Describe a topic:
```bash
docker exec -it kafka kafka-topics \
  --describe \
  --topic my-topic \
  --bootstrap-server localhost:9092
```

### Producing Messages

#### Using console producer:
```bash
docker exec -it kafka kafka-console-producer \
  --topic my-topic \
  --bootstrap-server localhost:9092
```

Then type messages (one per line) and press Ctrl+D when done.

#### Producing with key-value pairs:
```bash
docker exec -it kafka kafka-console-producer \
  --topic my-topic \
  --bootstrap-server localhost:9092 \
  --property "parse.key=true" \
  --property "key.separator=:"
```

### Consuming Messages

#### Using console consumer (from beginning):
```bash
docker exec -it kafka kafka-console-consumer \
  --topic my-topic \
  --from-beginning \
  --bootstrap-server localhost:9092
```

#### Consuming with key-value pairs:
```bash
docker exec -it kafka kafka-console-consumer \
  --topic my-topic \
  --from-beginning \
  --bootstrap-server localhost:9092 \
  --property print.key=true \
  --property key.separator=":"
```

#### Consuming from a specific consumer group:
```bash
docker exec -it kafka kafka-console-consumer \
  --topic my-topic \
  --bootstrap-server localhost:9092 \
  --group my-consumer-group
```

### Managing Consumer Groups

#### List all consumer groups:
```bash
docker exec -it kafka kafka-consumer-groups \
  --list \
  --bootstrap-server localhost:9092
```

#### Describe a consumer group:
```bash
docker exec -it kafka kafka-consumer-groups \
  --describe \
  --group my-consumer-group \
  --bootstrap-server localhost:9092
```

#### Reset consumer group offset:
```bash
docker exec -it kafka kafka-consumer-groups \
  --bootstrap-server localhost:9092 \
  --group my-consumer-group \
  --topic my-topic \
  --reset-offsets \
  --to-earliest \
  --execute
```

### Using Python Kafka Client

See the [examples/](./examples/) directory for Python producer and consumer scripts.