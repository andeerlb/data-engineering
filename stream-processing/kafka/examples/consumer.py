"""
Kafka Consumer Example

This script demonstrates how to consume messages from a Kafka topic.
"""

from kafka import KafkaConsumer
from kafka.errors import KafkaError
import json
from datetime import datetime

# Configuration
KAFKA_BOOTSTRAP_SERVERS = ['localhost:9092']
TOPIC_NAME = 'example-topic'
CONSUMER_GROUP_ID = 'example-consumer-group'


def json_deserializer(data):
    """Deserialize JSON bytes to Python dict"""
    return json.loads(data.decode('utf-8'))


def create_consumer(auto_offset_reset='earliest'):
    """
    Create and configure Kafka consumer
    
    Args:
        auto_offset_reset: Where to start reading messages
            - 'earliest': Start from the beginning, including old messages, if no committed offset exists, or if the committed offset is invalid (e.g., due to log retention)
            - 'latest': Start from the end (only new messages), if no committed offset exists, or if the committed offset is invalid
    """
    try:
        consumer = KafkaConsumer(
            TOPIC_NAME,
            bootstrap_servers=KAFKA_BOOTSTRAP_SERVERS,
            # Consumer group ID
            group_id=CONSUMER_GROUP_ID,
            # Deserialize message value from JSON
            value_deserializer=json_deserializer,
            # Where to start reading messages
            auto_offset_reset=auto_offset_reset,
            # Commit offsets automatically
            enable_auto_commit=True,
            # Commit interval in milliseconds
            auto_commit_interval_ms=1000,
            # Maximum number of records per poll
            max_poll_records=10,
        )
        print(f"Successfully connected to Kafka at {KAFKA_BOOTSTRAP_SERVERS}")
        print(f"Subscribed to topic: {TOPIC_NAME}")
        print(f"Consumer group: {CONSUMER_GROUP_ID}")
        print(f"Starting from: {auto_offset_reset}")
        print()
        return consumer
    except KafkaError as e:
        print(f"Failed to connect to Kafka: {e}")
        raise


def consume_messages(consumer):
    """Consume messages from Kafka topic"""
    print("=" * 60)
    print("Listening for messages... (Press Ctrl+C to stop)")
    print("=" * 60)
    print()
    
    message_count = 0
    
    try:
        for message in consumer:
            message_count += 1
            
            print(f"Message #{message_count} received:")
            print(f"   Topic: {message.topic}")
            print(f"   Partition: {message.partition}")
            print(f"   Offset: {message.offset}")
            print(f"   Timestamp: {datetime.fromtimestamp(message.timestamp/1000).isoformat()}")
            
            if message.key:
                print(f"   Key: {message.key.decode('utf-8')}")
            
            print(f"   Value: {json.dumps(message.value, indent=6)}")
            print("-" * 60)
            print()
            
    except KeyboardInterrupt:
        print(f"\nConsumer interrupted by user")
        print(f"Total messages consumed: {message_count}")
    except Exception as e:
        print(f"\nError occurred: {e}")
    finally:
        consumer.close()
        print("Consumer closed successfully")


def consume_with_manual_commit():
    """Consumer example with manual offset commit"""
    print("=" * 60)
    print("Consumer with Manual Commit")
    print("=" * 60)
    print()
    
    try:
        consumer = KafkaConsumer(
            TOPIC_NAME,
            bootstrap_servers=KAFKA_BOOTSTRAP_SERVERS,
            group_id=f"{CONSUMER_GROUP_ID}-manual",
            value_deserializer=json_deserializer,
            auto_offset_reset='earliest',
            # Disable auto commit
            enable_auto_commit=False,
        )
        
        print(f"Consumer created with manual commit mode")
        print(f"Listening for messages... (Press Ctrl+C to stop)\n")
        
        message_count = 0
        batch_size = 5
        
        for message in consumer:
            message_count += 1
            print(f"Message #{message_count}: {message.value.get('message', 'N/A')}")
            
            # Commit every batch_size messages
            if message_count % batch_size == 0:
                consumer.commit()
                print(f"Committed offset after {message_count} messages\n")
        
    except KeyboardInterrupt:
        print(f"\nConsumer interrupted by user")
        print(f"Total messages consumed: {message_count}")
        # Commit on shutdown
        consumer.commit()
        print("Final commit completed")
    except Exception as e:
        print(f"\nError occurred: {e}")
    finally:
        consumer.close()
        print("Consumer closed successfully")


def show_consumer_info(consumer):
    """Display consumer information"""
    print("\nConsumer Information:")
    print("-" * 60)
    
    # Get assigned partitions
    partitions = consumer.assignment()
    print(f"Assigned Partitions: {partitions}")
    
    # Get current position for each partition
    for partition in partitions:
        position = consumer.position(partition)
        print(f"  Partition {partition.partition}: Current offset = {position}")
    
    print("-" * 60)
    print()


def main():
    """Main function"""
    print("=" * 60)
    print("Kafka Consumer Example")
    print("=" * 60)
    print()
    
    # Choose consumer mode
    print("Select consumer mode:")
    print("1. Auto commit (recommended for beginners) - it means that the consumer will automatically commit offsets at regular intervals, which is simpler to use but may lead to duplicate processing in case of failures")
    print("2. Manual commit (more control) - it means that the consumer will not commit offsets automatically, and you need to call consumer.commit() manually to commit offsets, which gives you more control but requires careful handling to avoid data loss or duplicates")
    print("3. Latest messages only (skip old messages) - it means that the consumer will start reading from the end of the topic, so it will only receive new messages that are produced after the consumer starts, which is useful if you only care about real-time data and want to ignore historical messages")
    
    try:
        choice = input("\nEnter your choice (1-3) [default: 1]: ").strip() or "1"
        
        if choice == "1":
            consumer = create_consumer(auto_offset_reset='earliest')
            show_consumer_info(consumer)
            consume_messages(consumer)
        elif choice == "2":
            consume_with_manual_commit()
        elif choice == "3":
            consumer = create_consumer(auto_offset_reset='latest')
            print("⏭Skipping old messages, waiting for new ones...\n")
            show_consumer_info(consumer)
            consume_messages(consumer)
        else:
            print("Invalid choice. Exiting.")
            
    except Exception as e:
        print(f"Error: {e}")


if __name__ == "__main__":
    main()
