# Apache Avro - Data Serialization Framework

Apache Avro is a data serialization system that provides rich data structures, a compact binary format, and schema evolution capabilities. It was developed within the Apache Hadoop project and is widely used in Kafka ecosystems for efficient data exchange.

**Official Documentation**: https://avro.apache.org/docs/

## What is Avro?

Avro is a **data serialization framework** that:
- Defines data structures using **JSON-based schemas**
- Serializes data into a **compact binary format** for efficient storage and transmission
- Supports **schema evolution** to handle changing data requirements over time
- Works across **multiple programming languages** (Java, Python, C++, C#, etc.)

## Why Use Avro?

### 1. **Compact Binary Format**
- Avro serializes data into a compact binary format (much smaller than JSON or XML)
- No field names in the data (defined in the schema) = smaller message size
- Example: A JSON message of 500 bytes might be only 150 bytes in Avro

### 2. **Schema Evolution**
- Add new fields with default values (backward compatible)
- Remove optional fields (forward compatible)
- Rename fields (with aliases)
- Consumers and producers can use different schema versions safely

### 3. **Self-Describing**
- The schema defines the structure completely
- No need for manual parsing or field mapping
- Easy to understand data structure by reading the schema

### 4. **Type Safety**
- Strong typing prevents data corruption
- Validation happens automatically during serialization
- Catch errors early before data enters the pipeline

### 5. **Language Agnostic**
- Write producer in Java, consumer in Python - no problem!
- Same data format works across all languages
- Code generation available for static languages

## Key Features

### Rich Data Structures
Avro supports:
- **Primitive types**: null, boolean, int, long, float, double, bytes, string
- **Complex types**: records, enums, arrays, maps, unions, fixed
- **Logical types**: decimal, date, time-millis, timestamp-millis, UUID

### Compact Binary Format
```
JSON: {"id": "user123", "name": "John Doe", "age": 30}
Size: 52 bytes

Avro Binary: [0x00][0x01]...[binary data]...
Size: ~20 bytes (60% smaller!)
```

### Schema Storage Options
1. **Embedded in file** (for Avro files on disk)
2. **Embedded in message** (if you want self-contained messages)
3. **External registry** (Schema Registry - RECOMMENDED for Kafka)

### Remote Procedure Call (RPC)
- Avro can be used for RPC protocols (not just data serialization)
- Define services and methods in schemas
- Generate client/server code automatically

### Dynamic Typing
- **No code generation required** (unlike Protobuf or Thrift)
- Read and write data at runtime using GenericRecord
- Useful for dynamic applications and generic tools

## Avro Schemas

### Schema Definition

Avro schemas are defined in **JSON format**:

```json
{
  "type": "record",
  "name": "User",
  "namespace": "com.example",
  "doc": "A user record",
  "fields": [
    {
      "name": "id",
      "type": "string",
      "doc": "User unique identifier"
    },
    {
      "name": "username",
      "type": "string"
    },
    {
      "name": "age",
      "type": ["null", "int"],
      "default": null,
      "doc": "User age (optional)"
    },
    {
      "name": "email",
      "type": "string",
      "aliases": ["emailAddress"]
    }
  ]
}
```

### Primitive Types

```json
{
  "name": "example_primitives",
  "type": "record",
  "fields": [
    {"name": "is_active", "type": "boolean"},
    {"name": "count", "type": "int"},
    {"name": "big_number", "type": "long"},
    {"name": "price", "type": "float"},
    {"name": "precise_price", "type": "double"},
    {"name": "data", "type": "bytes"},
    {"name": "name", "type": "string"}
  ]
}
```

### Complex Types

#### Enum
```json
{
  "name": "status",
  "type": {
    "type": "enum",
    "name": "Status",
    "symbols": ["PENDING", "PROCESSING", "COMPLETED", "FAILED"]
  }
}
```

#### Array
```json
{
  "name": "tags",
  "type": {
    "type": "array",
    "items": "string"
  }
}
```

#### Map
```json
{
  "name": "properties",
  "type": {
    "type": "map",
    "values": "string"
  }
}
```

#### Union (Optional Fields)
```json
{
  "name": "middle_name",
  "type": ["null", "string"],
  "default": null
}
```

### Logical Types

Logical types provide semantic meaning to primitive types:

```json
{
  "name": "created_at",
  "type": "long",
  "logicalType": "timestamp-millis"
}

{
  "name": "amount",
  "type": "bytes",
  "logicalType": "decimal",
  "precision": 10,
  "scale": 2
}

{
  "name": "birth_date",
  "type": "int",
  "logicalType": "date"
}
```

## Wire Format

When using Schema Registry with Kafka, Avro messages follow this format:

1. **Magic Byte (0x00)**: Indicates this message contains a schema ID
2. **Schema ID**: 4-byte integer identifying the schema in Schema Registry
3. **Binary Data**: The actual message serialized with Avro

## Schema Evolution

Schema evolution allows you to change schemas over time while maintaining compatibility.

### Compatibility Types

#### 1. Backward Compatibility (BACKWARD)
- **New schema can read old data**
- Allowed changes:
  - Add fields with defaults
  - Remove fields
- Use case: New consumers read old messages

```json
// Old Schema
{
  "fields": [
    {"name": "id", "type": "string"},
    {"name": "name", "type": "string"}
  ]
}

// New Schema (Backward Compatible)
{
  "fields": [
    {"name": "id", "type": "string"},
    {"name": "name", "type": "string"},
    {"name": "age", "type": "int", "default": 0}  // Added with default
  ]
}
```

#### 2. Forward Compatibility (FORWARD)
- **Old schema can read new data**
- Allowed changes:
  - Add optional fields (with null union)
  - Remove fields with defaults
- Use case: Old consumers read new messages

#### 3. Full Compatibility (FULL)
- **Both forward AND backward compatible**
- Most restrictive but safest
- Only allows: Adding/removing optional fields with defaults

#### 4. None (NONE)
- No compatibility checks
- Dangerous - can break consumers
- Use only if you control all producers/consumers

### Schema Evolution Example

```python
# Version 1: Original Schema
{
  "type": "record",
  "name": "User",
  "fields": [
    {"name": "id", "type": "string"},
    {"name": "name", "type": "string"}
  ]
}

# Version 2: Add optional field (BACKWARD compatible)
{
  "type": "record",
  "name": "User",
  "fields": [
    {"name": "id", "type": "string"},
    {"name": "name", "type": "string"},
    {"name": "email", "type": ["null", "string"], "default": null}
  ]
}

# Version 3: Add required field with default (BACKWARD compatible)
{
  "type": "record",
  "name": "User",
  "fields": [
    {"name": "id", "type": "string"},
    {"name": "name", "type": "string"},
    {"name": "email", "type": ["null", "string"], "default": null},
    {"name": "created_at", "type": "long", "default": 0}
  ]
}
```

### Evolution Best Practices

1. **Always use default values** for new fields
2. **Never remove required fields** without defaults
3. **Use union types** for optional fields: `["null", "string"]`
4. **Test compatibility** before deploying schema changes
5. **Use Schema Registry** compatibility checks to prevent breaking changes

## Use Cases

### 1. Kafka Event Streaming

**Benefits**:
- Compact message size = lower storage costs
- Schema enforcement = data quality
- Evolution = zero-downtime upgrades

### 2. Hadoop Data Storage
- Avro files store both schema and data
- Splittable format (good for MapReduce)
- Native support in Hive, Spark, Flink

### 3. Database Change Data Capture (CDC)
- Debezium uses Avro to capture database changes
- Schema automatically derived from database schema
- Evolution handles table schema changes

### 4. Data Lake Ingestion
- Ingest data from multiple sources
- Single format for all data
- Schema catalog for data discovery

### 5. Microservices Communication
- Type-safe inter-service communication
- Language-agnostic data format
- Version management with Schema Registry