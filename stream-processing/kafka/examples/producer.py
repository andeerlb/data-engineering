"""
Kafka Producer Example

This script demonstrates how to produce messages to a Kafka topic.
"""

from kafka import KafkaProducer
from kafka.errors import KafkaError
import json
import time
from datetime import datetime

# Configuration
KAFKA_BOOTSTRAP_SERVERS = ['localhost:9092']
TOPIC_NAME = 'example-topic'


def json_serializer(data):
    """Serialize Python dict to JSON bytes"""
    return json.dumps(data).encode('utf-8')


def create_producer():
    """Create and configure Kafka producer"""
    try:
        producer = KafkaProducer(
            bootstrap_servers=KAFKA_BOOTSTRAP_SERVERS,
            value_serializer=json_serializer,
            # Acknowledge writes from all in-sync replicas
            acks='all',
            # Retry up to 3 times on failure
            retries=3,
            # Batch messages for efficiency
            batch_size=16384,
            # Wait up to 10ms to batch messages
            linger_ms=10,
            # Buffer memory
            buffer_memory=33554432,
        )
        print(f"Successfully connected to Kafka at {KAFKA_BOOTSTRAP_SERVERS}")
        return producer
    except KafkaError as e:
        print(f"Failed to connect to Kafka: {e}")
        raise


def produce_messages(producer, num_messages=10):
    """Produce sample messages to Kafka topic"""
    print(f"\nStarting to produce {num_messages} messages to topic '{TOPIC_NAME}'...\n")
    
    for i in range(num_messages):
        # Create sample message
        message = {
            'message_id': i,
            'timestamp': datetime.now().isoformat(),
            'message': f'This is message number {i}',
            'data': {
                'user_id': f'user_{i % 5}',
                'action': ['login', 'view', 'purchase', 'logout'][i % 4],
                'value': i * 10
            }
        }
        
        try:
            # Send message (async)
            future = producer.send(TOPIC_NAME, value=message)
            
            # Wait for message to be sent (make it synchronous for demo)
            record_metadata = future.get(timeout=10)
            
            print(f"Message {i} sent successfully:")
            print(f"   Topic: {record_metadata.topic}")
            print(f"   Partition: {record_metadata.partition}")
            print(f"   Offset: {record_metadata.offset}")
            print(f"   Data: {message}\n")
            
        except KafkaError as e:
            print(f"Failed to send message {i}: {e}")
        
        # Sleep for a bit to simulate real-world scenario
        time.sleep(0.5)
    
    # Ensure all messages are sent
    producer.flush()
    print(f"\nAll {num_messages} messages have been produced!\n")


def produce_with_key(producer, num_messages=5):
    """Produce messages with keys for partitioning"""
    print(f"\nProducing {num_messages} messages with keys...\n")
    
    for i in range(num_messages):
        key = f'key_{i % 3}'.encode('utf-8')  # Using 3 different keys
        message = {
            'message_id': i + 100,
            'timestamp': datetime.now().isoformat(),
            'message': f'Keyed message {i}',
        }
        
        try:
            future = producer.send(
                TOPIC_NAME,
                key=key,
                value=message
            )
            record_metadata = future.get(timeout=10)
            
            print(f"Message sent with key '{key.decode()}':")
            print(f"   Partition: {record_metadata.partition}")
            print(f"   Offset: {record_metadata.offset}\n")
            
        except KafkaError as e:
            print(f"Failed to send keyed message {i}: {e}")
        
        time.sleep(0.5)
    
    producer.flush()
    print(f"All keyed messages produced!\n")


def main():
    """Main function"""
    print("=" * 60)
    print("Kafka Producer Example")
    print("=" * 60)
    
    # Create producer
    producer = create_producer()
    
    try:
        # Produce simple messages
        produce_messages(producer, num_messages=10)
        
        # Produce messages with keys
        produce_with_key(producer, num_messages=5)
        
    except KeyboardInterrupt:
        print("\nProducer interrupted by user")
    except Exception as e:
        print(f"\nError occurred: {e}")
    finally:
        # Close producer
        producer.close()
        print("Producer closed successfully")


if __name__ == "__main__":
    main()
