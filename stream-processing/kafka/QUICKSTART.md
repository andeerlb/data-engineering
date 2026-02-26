# Quick Start Guide

Get up and running with Kafka in 5 minutes!

## Quick Setup

### 1. Start Kafka

```bash
docker-compose up -d
```

Wait about 10-15 seconds for services to be ready.

### 2. Verify Services

```bash
docker-compose ps
```

You should see all services running:
- `kafka`
- `zookeeper`
- `kafka-ui`
- `schema-registry`
- `kafka-connect`

### 3. Open Kafka UI

Go to http://localhost:8080 in your browser.

## Quick Commands

Using the Makefile (recommended):

```bash
# Create a topic
make create-topic TOPIC=my-topic

# List all topics
make list-topics

# Produce messages
make produce TOPIC=my-topic

# Consume messages
make consume TOPIC=my-topic
```

## Python Examples

### Setup

```bash
# Install dependencies
pip install -r examples/requirements.txt
```

### Run Producer

Terminal 1:
```bash
python examples/producer.py
```

### Run Consumer

Terminal 2:
```bash
python examples/consumer.py
```

### Create Topic

```bash
docker exec -it kafka kafka-topics \
  --create \
  --topic test-topic \
  --bootstrap-server localhost:9092 \
  --partitions 3 \
  --replication-factor 1
```

### Produce Messages

```bash
docker exec -it kafka kafka-console-producer \
  --topic test-topic \
  --bootstrap-server localhost:9092
```

Type messages and press Enter. Press Ctrl+D to exit.

### Consume Messages

```bash
docker exec -it kafka kafka-console-consumer \
  --topic test-topic \
  --from-beginning \
  --bootstrap-server localhost:9092
```

## Stopping

Stop services (keeps data):
```bash
docker-compose down
```

Stop and remove all data:
```bash
docker-compose down -v
```