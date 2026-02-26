# Kafka Examples

Python examples demonstrating Kafka producer and consumer patterns.

## Prerequisites

- Python 3.7 or higher
- Kafka cluster running (use [docker-compose](../docker-compose.yaml) in parent directory)

## Setup

1. **Install dependencies:**

```bash
# Create virtual environment
python -m venv venv

# Activate virtual environment
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt
```

2. **Start Kafka cluster:**

```bash
cd ..
docker-compose up -d
```

### Producer Example

The producer script demonstrates:
- Connecting to Kafka
- Producing JSON messages
- Producing messages with keys
- Error handling
- Asynchronous message sending

**Run the producer:**

```bash
python producer.py
```

- Sends 10 simple messages
- Sends 5 messages with keys for partitioning
- Displays message metadata (topic, partition, offset)
- Handles errors gracefully

### Consumer Example

- Different consumer modes (auto-commit, manual-commit)
- Reading from beginning or latest messages
- Consumer groups
- Offset management
- Deserialization

**Run the consumer:**

```bash
python consumer.py
```

**Options:**
1. Auto-commit mode (default) - messages consumed from beginning
2. Manual commit mode - explicit offset management
3. Latest mode - only consume new messages

## Configuration

Modify connection settings in the `.env` file.