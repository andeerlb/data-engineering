"""
Kafka Consumer with Avro Deserialization

This script demonstrates how to consume messages from a Kafka topic using Avro deserialization
with automatic schema retrieval from Schema Registry.

Key Features:
- Automatic schema retrieval by ID from Schema Registry
- Type-safe deserialization with Avro
- Supports schema evolution (backward/forward compatibility)
- No need to know the schema in advance
"""

from confluent_kafka import Consumer, KafkaError
from confluent_kafka.serialization import SerializationContext, MessageField
from confluent_kafka.schema_registry import SchemaRegistryClient
from confluent_kafka.schema_registry.avro import AvroDeserializer
from datetime import datetime

# Configuration
KAFKA_BOOTSTRAP_SERVERS = 'localhost:9092'
SCHEMA_REGISTRY_URL = 'http://localhost:8081'
TOPIC_NAME = 'transactions-avro'
CONSUMER_GROUP = 'avro-consumer-group'


def dict_to_transaction(obj, ctx):
    """
    Convert dictionary to Transaction object after Avro deserialization.
    This is optional - you can work directly with dictionaries.
    """
    if obj is None:
        return None
    
    return {
        'transaction_id': obj['transaction_id'],
        'user_id': obj['user_id'],
        'amount': obj['amount'],
        'currency': obj['currency'],
        'timestamp': obj['timestamp'],
        'status': obj['status']
    }


def format_transaction(transaction):
    """
    Format transaction dictionary for display.
    """
    if transaction is None:
        return "None"
    
    timestamp_ms = transaction['timestamp']
    dt = datetime.fromtimestamp(timestamp_ms / 1000.0)
    
    return (
        f"\nTransaction Details:"
        f"\n     ID: {transaction['transaction_id']}"
        f"\n     User: {transaction['user_id']}"
        f"\n     Amount: ${transaction['amount']:.2f} {transaction['currency']}"
        f"\n     Status: {transaction['status']}"
        f"\n     Time: {dt.strftime('%Y-%m-%d %H:%M:%S')}"
    )


def create_consumer_with_avro():
    """
    Creates a Kafka consumer configured with Avro deserialization.
    
    The AvroDeserializer will automatically:
    1. Read the schema ID from the message header
    2. Fetch the schema from Schema Registry (and cache it)
    3. Deserialize the message using the correct schema
    4. Handle schema evolution transparently
    
    Returns:
        tuple: (Consumer, AvroDeserializer)
    """
    # Schema Registry client configuration
    schema_registry_conf = {'url': SCHEMA_REGISTRY_URL}
    schema_registry_client = SchemaRegistryClient(schema_registry_conf)
    
    # Create AvroDeserializer
    # Note: We don't need to specify the schema!
    # The deserializer will automatically fetch it from Schema Registry
    # based on the schema ID embedded in each message
    avro_deserializer = AvroDeserializer(
        schema_registry_client=schema_registry_client,
        from_dict=dict_to_transaction
    )
    
    # Kafka consumer configuration
    consumer_conf = {
        'bootstrap.servers': KAFKA_BOOTSTRAP_SERVERS,
        'group.id': CONSUMER_GROUP,
        'auto.offset.reset': 'earliest',  # Start from beginning if no committed offset
        'enable.auto.commit': True,
        'client.id': 'avro-consumer-example'
    }
    
    consumer = Consumer(consumer_conf)
    
    print(f"Consumer created successfully")
    print(f"   Kafka Broker: {KAFKA_BOOTSTRAP_SERVERS}")
    print(f"   Schema Registry: {SCHEMA_REGISTRY_URL}")
    print(f"   Topic: {TOPIC_NAME}")
    print(f"   Consumer Group: {CONSUMER_GROUP}")
    print(f"   Schema will be auto-fetched from Schema Registry\n")
    
    return consumer, avro_deserializer


def consume_transactions(consumer, avro_deserializer):
    """
    Consume and deserialize Avro messages from Kafka.
    
    The deserializer will automatically:
    1. Read the magic byte and schema ID from the message
    2. Fetch the schema from Schema Registry (cached after first fetch)
    3. Deserialize the Avro binary data
    4. Convert to Python dictionary
    """
    # Subscribe to topic
    consumer.subscribe([TOPIC_NAME])
    
    print(f"Starting to consume Avro-serialized transactions...")
    print(f"   Press Ctrl+C to stop\n")
    print("=" * 80)
    
    message_count = 0
    
    try:
        while True:
            # Poll for messages (timeout in seconds)
            msg = consumer.poll(timeout=1.0)
            
            if msg is None:
                # No message available within timeout
                continue
            
            if msg.error():
                if msg.error().code() == KafkaError._PARTITION_EOF:
                    # End of partition event
                    print(f"Reached end of partition {msg.partition()} at offset {msg.offset()}")
                else:
                    print(f"Consumer error: {msg.error()}")
                continue
            
            message_count += 1
            
            try:
                # Deserialize the Avro message
                # The AvroDeserializer will:
                # 1. Extract the schema ID from the message (first 5 bytes)
                # 2. Look up the schema in its cache or fetch from Schema Registry
                # 3. Deserialize the remaining bytes using that schema
                # 4. Call dict_to_transaction() to convert to our preferred format
                transaction = avro_deserializer(
                    msg.value(),
                    SerializationContext(msg.topic(), MessageField.VALUE)
                )
                
                print(f"\nMessage #{message_count} received:")
                print(f"   Topic: {msg.topic()}")
                print(f"   Partition: {msg.partition()}")
                print(f"   Offset: {msg.offset()}")
                print(f"   Key: {msg.key().decode('utf-8') if msg.key() else 'None'}")
                print(format_transaction(transaction))
                print("=" * 80)
                
            except Exception as e:
                print(f"Error deserializing message: {e}")
                print(f"   Message offset: {msg.offset()}")
                continue
    
    except KeyboardInterrupt:
        print("\n\n⏹Consumer stopped by user")
    
    finally:
        # Close consumer to commit final offsets
        print("\nClosing consumer...")
        consumer.close()
        print(f"✨ Total messages consumed: {message_count}")


def verify_schema_compatibility():
    """
    Demonstrate schema evolution by showing all schema versions.
    """
    print("Checking schema versions in Schema Registry...\n")
    
    import requests
    
    subject = f"{TOPIC_NAME}-value"
    
    # Get all versions
    response = requests.get(f"{SCHEMA_REGISTRY_URL}/subjects/{subject}/versions")
    
    if response.status_code == 200:
        versions = response.json()
        print(f"Found {len(versions)} schema version(s) for subject '{subject}':")
        
        for version in versions:
            version_response = requests.get(
                f"{SCHEMA_REGISTRY_URL}/subjects/{subject}/versions/{version}"
            )
            
            if version_response.status_code == 200:
                schema_info = version_response.json()
                print(f"\n   Version {version}:")
                print(f"   - Schema ID: {schema_info['id']}")
                print(f"   - URL: {SCHEMA_REGISTRY_URL}/subjects/{subject}/versions/{version}")
        
        print("\nThe consumer can read messages written with any of these schema versions!")
        print("   This is the power of schema evolution with Avro + Schema Registry.\n")
    else:
        print(f"Could not fetch schema versions: {response.text}")


if __name__ == "__main__":
    print("=" * 80)
    print("Kafka Avro Consumer - Automatic Schema Retrieval Demo")
    print("=" * 80)
    print()
    
    # Show schema versions
    verify_schema_compatibility()
    
    print("=" * 80)
    print()
    
    # Create consumer with Avro deserialization
    consumer, avro_deserializer = create_consumer_with_avro()
    
    # Start consuming messages
    # The schema will be automatically fetched from Schema Registry!
    consume_transactions(consumer, avro_deserializer)
    
    print("\n" + "=" * 80)
    print("Demo completed!")
    print("=" * 80)
