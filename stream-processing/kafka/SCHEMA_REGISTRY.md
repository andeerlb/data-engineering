# Confluent Schema Registry

A centralized repository for managing and validating schemas for Kafka topics. Schema Registry ensures data quality, enables schema evolution, and provides compatibility guarantees for your data pipelines.

**Official Documentation**: https://docs.confluent.io/platform/current/schema-registry/index.html

## What is Schema Registry?

**Schema Registry** is a centralized service that stores and manages schemas for Kafka topics. Think of it as a database for schemas that sits alongside your Kafka cluster.

### Core Functions

1. **Schema Storage**: Central repository for all your Avro/Protobuf/JSON schemas
2. **Schema Versioning**: Track multiple versions of schemas over time
3. **Compatibility Checking**: Validate that schema changes won't break consumers
4. **Schema Evolution**: Allow schemas to change while maintaining data compatibility
5. **ID Management**: Assign unique IDs to schemas for efficient message encoding

### Architecture

```
┌─────────────┐         ┌──────────────────┐         ┌─────────────┐
│  Producer   │────────▶│ Schema Registry  │◀────────│  Consumer   │
│             │         │                  │         │             │
│ 1. Register │         │ • Store schemas  │         │ 3. Fetch    │
│    schema   │         │ • Check compat.  │         │    schema   │
│             │         │ • Assign IDs     │         │             │
│ 2. Get ID   │         │ • Serve lookups  │         │ 4. Cache    │
└─────────────┘         └──────────────────┘         └─────────────┘
       │                                                     │
       │                                                     │
       ▼                                                     ▼
┌─────────────────────────────────────────────────────────────────┐
│                         Kafka Cluster                           │
│                                                                 │
│   Messages: [magic byte][schema ID][binary data]               │
└─────────────────────────────────────────────────────────────────┘
```

## Why Do You Need It?

**Problems**:
- No central source of truth for data structure
- Silent data corruption (wrong fields, types)
- Breaking changes deployed without validation
- No way to track schema versions
- Difficult to debug data issues

### Solution With Schema Registry

**Benefits**:
- Centralized schema management
- Automatic compatibility validation
- Version tracking and history
- Prevents breaking changes
- Efficient message encoding (just 5 bytes overhead)

## How It Works

### 1. Schema Registration Flow

```python
# Producer code (Python)
from confluent_kafka import Producer
from confluent_kafka.schema_registry import SchemaRegistryClient
from confluent_kafka.schema_registry.avro import AvroSerializer

# Define schema
schema_str = """
{
    "type": "record",
    "name": "User",
    "fields": [
        {"name": "id", "type": "string"},
        {"name": "name", "type": "string"}
    ]
}
"""

# Create Schema Registry client
schema_registry_client = SchemaRegistryClient({'url': 'http://localhost:8081'})

# Create Avro serializer
# On first use, this will:
# 1. Send schema to Schema Registry
# 2. Schema Registry validates it
# 3. Schema Registry assigns a unique ID
# 4. Returns the ID to the serializer
# 5. Serializer caches the ID
avro_serializer = AvroSerializer(
    schema_registry_client=schema_registry_client,
    schema_str=schema_str
)

# Create producer
producer = Producer({'bootstrap.servers': 'localhost:9092'})

# Produce message
# The serializer will:
# 1. Serialize data to Avro binary
# 2. Prefix with magic byte (0x00) and schema ID
# 3. Send to Kafka
producer.produce(
    topic='users',
    value=avro_serializer(user_dict, ctx)
)
```

### 2. Schema Retrieval Flow

```python
# Consumer code (Python)
from confluent_kafka import Consumer
from confluent_kafka.schema_registry.avro import AvroDeserializer

# Create deserializer (no schema needed!)
avro_deserializer = AvroDeserializer(schema_registry_client)

# Consume message
msg = consumer.poll(1.0)

# The deserializer will:
# 1. Read magic byte and schema ID from message
# 2. Check its cache for the schema
# 3. If not cached: fetch from Schema Registry
# 4. Cache the schema for future messages
# 5. Deserialize the binary data
# 6. Return Python object
user = avro_deserializer(msg.value(), ctx)
```

### 3. Message Wire Format

```
Kafka Message Structure:
┌────────────┬─────────────┬────────────────────────┐
│ Magic Byte │  Schema ID  │    Avro Binary Data    │
│  (1 byte)  │  (4 bytes)  │      (variable)        │
│   0x00     │  0x00000001 │  [binary encoded...]   │
└────────────┴─────────────┴────────────────────────┘
     │             │                   │
     │             │                   └─ Actual message data
     │             │
     │             └─ References schema in Schema Registry
     │
     └─ Indicator that schema ID follows
```

**Size Comparison**:

| Format | Overhead | Example Message Size |
|--------|----------|---------------------|
| JSON with schema embedded | ~1 KB schema | ~1.2 KB |
| Avro with schema embedded | ~1 KB schema | ~1.05 KB |
| **Avro with Schema Registry** | **5 bytes** | **~80 bytes** |

**Savings**: ~93% reduction in message size!

## Key Concepts

### Subjects

A **subject** is a named scope in which schemas evolve. 

**Default naming strategy**: `{topic}-{key|value}`

Examples:
- `users-value` - Schema for values in `users` topic
- `users-key` - Schema for keys in `users` topic
- `orders-value` - Schema for values in `orders` topic

```bash
# List all subjects
curl http://localhost:8081/subjects

# Response:
["users-value", "users-key", "orders-value"]
```

### Schema Versions

Each subject can have multiple versions:

```
Subject: users-value
  ├─ Version 1 (Schema ID: 1) - {id, name}
  ├─ Version 2 (Schema ID: 2) - {id, name, email}
  └─ Version 3 (Schema ID: 3) - {id, name, email, age}
```

**Important**: 
- Version numbers are per-subject (1, 2, 3...)
- Schema IDs are global and unique (1, 2, 3, 4, 5...)
- Multiple subjects can reference the same schema ID

### Schema IDs

- **Globally unique** across all subjects
- **Immutable** - once assigned, never changes
- **Sequential** - 1, 2, 3, 4, ...
- **Efficient** - Only 4 bytes in message header

```
Global Schema Registry:
  Schema ID 1 → {id, name}           (used by users-value v1)
  Schema ID 2 → {id, email}          (used by subscribers-value v1)
  Schema ID 3 → {id, name, email}    (used by users-value v2)
  Schema ID 4 → {order_id, amount}   (used by orders-value v1)
```

---

## Compatibility Modes

Schema Registry enforces compatibility rules to prevent breaking changes.

### BACKWARD (Default)

**New schema can read OLD data**

Allowed:
- Add fields with defaults
- Remove fields

Not allowed:
- Add required fields (no default)
- Change field types

```json
// Version 1
{"fields": [{"name": "id", "type": "string"}]}

// Version 2 (BACKWARD compatible)
{"fields": [
  {"name": "id", "type": "string"},
  {"name": "email", "type": "string", "default": ""}  // Added with default
]}
```

**Use case**: Upgrade consumers first, then producers

### FORWARD

**Old schema can read NEW data**

Allowed:
- Add optional fields (unions with null)
- Remove fields with defaults

Not allowed:
- Add required fields
- Remove fields without defaults

```json
// Version 1
{"fields": [
  {"name": "id", "type": "string"},
  {"name": "name", "type": "string"}
]}

// Version 2 (FORWARD compatible)
{"fields": [
  {"name": "id", "type": "string"},
  {"name": "name", "type": "string"},
  {"name": "email", "type": ["null", "string"], "default": null}  // Optional
]}
```

**Use case**: Upgrade producers first, then consumers

### FULL

**Both BACKWARD and FORWARD**

Allowed:
- Add optional fields with defaults
- Remove optional fields with defaults

Not allowed:
- Add/remove required fields
- Change field types

```json
// Version 1
{"fields": [
  {"name": "id", "type": "string"},
  {"name": "name", "type": "string", "default": ""}
]}

// Version 2 (FULL compatible)
{"fields": [
  {"name": "id", "type": "string"},
  {"name": "name", "type": "string", "default": ""},
  {"name": "age", "type": "int", "default": 0}  // Optional with default
]}
```

**Use case**: Most flexible deployment (upgrade in any order)

### NONE

**No compatibility checks**

**Dangerous** - can break consumers!

Use only when:
- You control all producers and consumers
- You can coordinate deployments
- You're okay with potential downtime

---

## Automatic Schema Registration

### How It Works

When you produce a message with `AvroSerializer`:

```python
avro_serializer = AvroSerializer(
    schema_registry_client=schema_registry_client,
    schema_str=MY_SCHEMA
)

# First time this runs:
producer.produce(topic='my-topic', value=avro_serializer(data, ctx))
```

**Behind the scenes**:

1. **Serializer checks**: "Have I registered this schema before?"
   - If cached → use cached schema ID → skip to step 6

2. **Serializer → Schema Registry**: "Do you have this schema?"
   ```
   POST /subjects/my-topic-value/versions
   Body: {"schema": "{\"type\":\"record\"...}"}
   ```

3. **Schema Registry checks**:
   - Is there an existing schema for this subject?
   - If yes: Is the new schema compatible?
   - If compatible: Assign schema ID

4. **Schema Registry → Serializer**: 
   ```json
   {"id": 1}
   ```

5. **Serializer caches** the schema ID

6. **Serialize message**:
   ```
   [0x00][0x00 0x00 0x00 0x01][...avro binary data...]
    magic     schema ID=1      actual data
   ```

7. **Send to Kafka**

### Registration Happens When

**First message** with a new schema  
**Schema changes** (new version)

### Configuration Options

```python
# Auto-register schemas (default: True)
avro_serializer = AvroSerializer(
    schema_registry_client,
    schema_str,
    conf={'auto.register.schemas': True}  # Register if not exists
)

# Use latest version without registering
avro_serializer = AvroSerializer(
    schema_registry_client,
    schema_str,
    conf={
        'auto.register.schemas': False,  # Don't register
        'use.latest.version': True       # Use latest existing version
    }
)
```

## REST API

Schema Registry provides a RESTful API for schema management.

### Common Endpoints

#### List all subjects
```bash
curl http://localhost:8081/subjects

# Response:
["users-value", "orders-value"]
```

#### Get all versions of a subject
```bash
curl http://localhost:8081/subjects/users-value/versions

# Response:
[1, 2, 3]
```

#### Get a specific schema version
```bash
curl http://localhost:8081/subjects/users-value/versions/1

# Response:
{
  "subject": "users-value",
  "version": 1,
  "id": 1,
  "schema": "{\"type\":\"record\",\"name\":\"User\",\"fields\":[{\"name\":\"id\",\"type\":\"string\"}]}"
}
```

#### Get latest schema
```bash
curl http://localhost:8081/subjects/users-value/versions/latest
```

#### Get schema by ID
```bash
curl http://localhost:8081/schemas/ids/1

# Response:
{
  "schema": "{\"type\":\"record\",\"name\":\"User\",\"fields\":[...]}"
}
```

#### Register a new schema
```bash
curl -X POST http://localhost:8081/subjects/users-value/versions \
  -H "Content-Type: application/vnd.schemaregistry.v1+json" \
  -d '{
    "schema": "{\"type\":\"record\",\"name\":\"User\",\"fields\":[{\"name\":\"id\",\"type\":\"string\"},{\"name\":\"name\",\"type\":\"string\"}]}"
  }'

# Response:
{"id": 1}
```

#### Check compatibility
```bash
curl -X POST http://localhost:8081/compatibility/subjects/users-value/versions/latest \
  -H "Content-Type: application/vnd.schemaregistry.v1+json" \
  -d '{
    "schema": "{\"type\":\"record\",\"name\":\"User\",\"fields\":[{\"name\":\"id\",\"type\":\"string\"},{\"name\":\"age\",\"type\":\"int\",\"default\":0}]}"
  }'

# Response:
{"is_compatible": true}
```

#### Get compatibility mode
```bash
curl http://localhost:8081/config/users-value

# Response:
{"compatibilityLevel": "BACKWARD"}
```

#### Set compatibility mode
```bash
curl -X PUT http://localhost:8081/config/users-value \
  -H "Content-Type: application/vnd.schemaregistry.v1+json" \
  -d '{"compatibility": "FULL"}'
```

#### Delete a subject
```bash
# Soft delete (can be restored)
curl -X DELETE http://localhost:8081/subjects/users-value

# Permanent delete
curl -X DELETE http://localhost:8081/subjects/users-value?permanent=true
```

---

## Best Practices

### 1. Always Use Default Values

```json
// Bad: Required field (breaks backward compatibility)
{
  "name": "email",
  "type": "string"
}

// Good: Field with default
{
  "name": "email",
  "type": "string",
  "default": ""
}

// Better: Optional field
{
  "name": "email",
  "type": ["null", "string"],
  "default": null
}
```

### 2. Use Meaningful Names

```json
// Bad
{"name": "Transaction", "namespace": "com.example"}
// Subject: my-topic-value (not descriptive)

// Good
{"name": "PaymentTransaction", "namespace": "com.company.payments"}
// Subject: payment-transactions-value (clear purpose)
```

### 3. Document Your Schemas

```json
{
  "type": "record",
  "name": "User",
  "doc": "User account information",
  "fields": [
    {
      "name": "user_id",
      "type": "string",
      "doc": "Unique user identifier (UUID format)"
    },
    {
      "name": "created_at",
      "type": "long",
      "logicalType": "timestamp-millis",
      "doc": "Account creation timestamp in milliseconds since epoch"
    }
  ]
}
```

### 4. Test Compatibility Before Deployment

```bash
# Before deploying new schema version:
curl -X POST http://localhost:8081/compatibility/subjects/users-value/versions/latest \
  -H "Content-Type: application/vnd.schemaregistry.v1+json" \
  -d @new-schema.json

# Only deploy if response is: {"is_compatible": true}
```

### 5. Use Logical Types

```json
// Bad: Unclear timestamp format
{"name": "created_at", "type": "long"}

// Good: Clear semantic meaning
{
  "name": "created_at",
  "type": "long",
  "logicalType": "timestamp-millis"
}

// Bad: Floating point for money
{"name": "amount", "type": "double"}

// Good: Precise decimal
{
  "name": "amount",
  "type": "bytes",
  "logicalType": "decimal",
  "precision": 10,
  "scale": 2
}
```

### 6. Choose the Right Compatibility Mode

| Scenario | Recommended Mode |
|----------|------------------|
| Fast-moving microservices | FULL |
| Legacy systems (upgrade consumers first) | BACKWARD |
| New data fields frequently added | BACKWARD |
| Fields sometimes removed | FORWARD |
| Strict API contracts | FULL |
| Experimental/dev environments | NONE (with caution) |

**Quick Reference:**

- **FULL** → Both old and new code can read both old and new data (safest, most flexible)
- **BACKWARD** → New consumers can read old messages (default - upgrade consumers first, then producers)
- **FORWARD** → Old consumers can read new messages (upgrade producers first, then consumers)
- **NONE** → No compatibility checks - breaking changes allowed (dangerous - use only with full control)

### 7. Monitor Schema Registry

```bash
# Health check
curl http://localhost:8081/

# List all schemas (audit)
curl http://localhost:8081/subjects

# Check schema evolution
curl http://localhost:8081/subjects/my-topic-value/versions
```

## Common Operations

### Operation 1: Register a Schema Manually

```bash
# Method 1: Using curl
curl -X POST http://localhost:8081/subjects/transactions-avro-value/versions \
  -H "Content-Type: application/vnd.schemaregistry.v1+json" \
  -d '{
    "schema": "{\"type\":\"record\",\"name\":\"Transaction\",\"fields\":[{\"name\":\"id\",\"type\":\"string\"},{\"name\":\"amount\",\"type\":\"double\"}]}"
  }'

# Method 2: Using a file
cat > transaction-schema.json <<EOF
{
  "schema": "{\"type\":\"record\",\"name\":\"Transaction\",\"namespace\":\"com.example\",\"fields\":[{\"name\":\"transaction_id\",\"type\":\"string\"},{\"name\":\"amount\",\"type\":\"double\"},{\"name\":\"timestamp\",\"type\":\"long\"}]}"
}
EOF

curl -X POST http://localhost:8081/subjects/transactions-avro-value/versions \
  -H "Content-Type: application/vnd.schemaregistry.v1+json" \
  -d @transaction-schema.json
```

### Operation 2: Evolve a Schema

```bash
# Version 1 already exists with: {id, amount}

# Register Version 2 with new field
curl -X POST http://localhost:8081/subjects/transactions-avro-value/versions \
  -H "Content-Type: application/vnd.schemaregistry.v1+json" \
  -d '{
    "schema": "{\"type\":\"record\",\"name\":\"Transaction\",\"fields\":[{\"name\":\"id\",\"type\":\"string\"},{\"name\":\"amount\",\"type\":\"double\"},{\"name\":\"currency\",\"type\":\"string\",\"default\":\"USD\"}]}"
  }'

# Verify
curl http://localhost:8081/subjects/transactions-avro-value/versions
# Response: [1, 2]
```

### Operation 3: View Schema History

```bash
# Get all versions
curl http://localhost:8081/subjects/users-value/versions | jq .

# View each version
for version in $(curl -s http://localhost:8081/subjects/users-value/versions | jq -r '.[]'); do
  echo "=== Version $version ==="
  curl -s http://localhost:8081/subjects/users-value/versions/$version | jq .
done
```

### Operation 4: Test Schema Compatibility

```python
# test_compatibility.py
import requests
import json

schema_registry_url = "http://localhost:8081"
subject = "users-value"

new_schema = {
    "type": "record",
    "name": "User",
    "fields": [
        {"name": "id", "type": "string"},
        {"name": "name", "type": "string"},
        {"name": "email", "type": "string", "default": ""}  # New field
    ]
}

response = requests.post(
    f"{schema_registry_url}/compatibility/subjects/{subject}/versions/latest",
    headers={"Content-Type": "application/vnd.schemaregistry.v1+json"},
    json={"schema": json.dumps(new_schema)}
)

result = response.json()
if result.get("is_compatible"):
    print("chema is compatible!")
else:
    print("Schema is NOT compatible!")
    print(f"Error: {result}")
```

### Operation 5: Delete Old Schemas

```bash
# Soft delete (can be restored)
curl -X DELETE http://localhost:8081/subjects/old-topic-value

# Verify deletion
curl http://localhost:8081/subjects

# Permanent delete
curl -X DELETE http://localhost:8081/subjects/old-topic-value?permanent=true
```