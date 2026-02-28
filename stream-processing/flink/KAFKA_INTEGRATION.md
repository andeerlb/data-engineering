# Flink + Kafka Integration

This guide explains how Apache Flink and Apache Kafka work together in this environment.

## How It Works

Flink connects to Kafka's Docker network (`kafka-network`), allowing Flink containers to access Kafka services using hostnames:

- **kafka:29092** - For internal connections (between containers)
- **localhost:9092** - For external connections (from host)

## Starting Services

### Recommended Order

1. **Start Kafka first**:
   ```bash
   cd stream-processing/kafka
   docker-compose up -d
   ```

2. **Then start Flink**:
   ```bash
   cd ../flink
   docker-compose up -d
   ```

3. **Verify connectivity**:
   ```bash
   # View networks
   docker network ls | grep kafka
   
   # View containers on Kafka network
   docker network inspect kafka-kafka-network
   ```

### Alternative Order

You can also start Flink only (without Kafka) if you don't need integration:

```bash
cd stream-processing/flink
docker-compose up -d
```

## Flink Job Configuration

### Bootstrap Servers

Inside your Flink jobs, use:

```java
// Java
properties.setProperty("bootstrap.servers", "kafka:29092");
```

```python
# Python
kafka_source = KafkaSource.builder() \
    .set_bootstrap_servers("kafka:29092") \
    .build()
```