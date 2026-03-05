"""
Kafka Producer with Avro Serialization and Automatic Schema Registration

This script demonstrates how to produce messages to a Kafka topic using Avro serialization
with automatic schema registration to Schema Registry.

Key Features:
- Automatic schema registration to Schema Registry
- Schema evolution support
- Type-safe serialization with Avro
- Backward/Forward compatibility validation
"""

from confluent_kafka import Producer
from confluent_kafka.serialization import SerializationContext, MessageField
from confluent_kafka.schema_registry import SchemaRegistryClient
from confluent_kafka.schema_registry.avro import AvroSerializer
import time
from datetime import datetime

# Configuration
KAFKA_BOOTSTRAP_SERVERS = 'localhost:9092'
SCHEMA_REGISTRY_URL = 'http://localhost:8081'
TOPIC_NAME = 'transactions-avro'

# Define Avro Schema
# This schema will be AUTOMATICALLY registered when the first message is produced
TRANSACTION_SCHEMA = """
{
  "type": "record",
  "name": "Transaction",
  "namespace": "com.example",
  "doc": "A financial transaction record",
  "fields": [
    {
      "name": "transaction_id",
      "type": "string",
      "doc": "Unique transaction identifier"
    },
    {
      "name": "user_id",
      "type": "string",
      "doc": "User identifier who made the transaction"
    },
    {
      "name": "amount",
      "type": "double",
      "doc": "Transaction amount in dollars"
    },
    {
      "name": "currency",
      "type": "string",
      "default": "USD",
      "doc": "Currency code (ISO 4217)"
    },
    {
      "name": "timestamp",
      "type": "long",
      "logicalType": "timestamp-millis",
      "doc": "Transaction timestamp in milliseconds since epoch"
    },
    {
      "name": "status",
      "type": {
        "type": "enum",
        "name": "TransactionStatus",
        "symbols": ["PENDING", "COMPLETED", "FAILED", "CANCELLED"]
      },
      "default": "PENDING",
      "doc": "Current transaction status"
    }
  ]
}
"""


class Transaction:
    """
    Python class representing a Transaction.
    This will be serialized to Avro format before sending to Kafka.
    """
    def __init__(self, transaction_id, user_id, amount, currency, timestamp, status):
        self.transaction_id = transaction_id
        self.user_id = user_id
        self.amount = amount
        self.currency = currency
        self.timestamp = timestamp
        self.status = status


def transaction_to_dict(transaction, ctx):
    """
    Convert Transaction object to dictionary for Avro serialization.
    This is the serialization callback function.
    """
    return {
        'transaction_id': transaction.transaction_id,
        'user_id': transaction.user_id,
        'amount': transaction.amount,
        'currency': transaction.currency,
        'timestamp': transaction.timestamp,
        'status': transaction.status
    }


def delivery_report(err, msg):
    """
    Callback function called once message delivery is complete.
    Reports delivery success or failure.
    """
    if err is not None:
        print(f'Message delivery failed: {err}')
    else:
        print(f'Message delivered to topic: {msg.topic()} '
              f'[partition: {msg.partition()}, offset: {msg.offset()}]')


def create_producer_with_avro():
    """
    Creates a Kafka producer configured with Avro serialization.
    
    The AvroSerializer will automatically:
    1. Register the schema with Schema Registry (if not already registered)
    2. Check compatibility with existing schemas
    3. Serialize messages using the schema
    4. Include schema ID in the message header
    
    Returns:
        tuple: (Producer, AvroSerializer)
    """
    # Schema Registry client configuration
    schema_registry_conf = {'url': SCHEMA_REGISTRY_URL}
    schema_registry_client = SchemaRegistryClient(schema_registry_conf)
    
    # Create AvroSerializer with automatic schema registration
    # When the first message is sent, the schema will be registered automatically
    # under the subject: "{topic_name}-value" (e.g., "transactions-avro-value")
    avro_serializer = AvroSerializer(
        schema_registry_client=schema_registry_client,
        schema_str=TRANSACTION_SCHEMA,
        to_dict=transaction_to_dict
    )
    
    # Kafka producer configuration
    producer_conf = {
        'bootstrap.servers': KAFKA_BOOTSTRAP_SERVERS,
        'client.id': 'avro-producer-example'
    }
    
    producer = Producer(producer_conf)
    
    print(f"Producer created successfully")
    print(f"   Kafka Broker: {KAFKA_BOOTSTRAP_SERVERS}")
    print(f"   Schema Registry: {SCHEMA_REGISTRY_URL}")
    print(f"   Topic: {TOPIC_NAME}")
    print(f"   Schema will be auto-registered as: {TOPIC_NAME}-value\n")
    
    return producer, avro_serializer


def produce_sample_transactions(producer, avro_serializer, num_messages=5):
    """
    Produce sample transactions with Avro serialization.
    
    The first message will trigger automatic schema registration.
    Subsequent messages will use the registered schema.
    """
    print(f"Starting to produce {num_messages} Avro-serialized transactions...\n")
    
    for i in range(num_messages):
        # Create a transaction
        transaction = Transaction(
            transaction_id=f"TXN-{i+1000}",
            user_id=f"user_{i % 3}",
            amount=round(100.50 + (i * 25.75), 2),
            currency="USD",
            timestamp=int(datetime.now().timestamp() * 1000),  # milliseconds since epoch
            status=["PENDING", "COMPLETED", "FAILED"][i % 3]
        )
        
        print(f"Transaction {i+1}:")
        print(f"  ID: {transaction.transaction_id}")
        print(f"  User: {transaction.user_id}")
        print(f"  Amount: ${transaction.amount} {transaction.currency}")
        print(f"  Status: {transaction.status}")
        
        try:
            # Serialize and send the message
            # The AvroSerializer will:
            # 1. Convert the Transaction object to dict using transaction_to_dict()
            # 2. Validate against the Avro schema
            # 3. Serialize to Avro binary format
            # 4. On first message: Register schema to Schema Registry
            # 5. Prefix the message with schema ID (magic byte + schema ID)
            producer.produce(
                topic=TOPIC_NAME,
                key=transaction.transaction_id,
                value=avro_serializer(
                    transaction,
                    SerializationContext(TOPIC_NAME, MessageField.VALUE)
                ),
                on_delivery=delivery_report
            )
            
            # Trigger delivery reports
            producer.poll(0)
            
        except Exception as e:
            print(f"Failed to produce message: {e}")
        
        print()
        time.sleep(1)
    
    # Wait for all messages to be delivered
    print("Flushing producer...")
    producer.flush()
    print(f"\nAll {num_messages} transactions have been produced!\n")


def verify_schema_registration():
    """
    Verify that the schema was automatically registered in Schema Registry.
    """
    print("Verifying schema registration...\n")
    
    import requests
    
    # Check if schema was registered
    subject = f"{TOPIC_NAME}-value"
    response = requests.get(f"{SCHEMA_REGISTRY_URL}/subjects/{subject}/versions/latest")
    
    if response.status_code == 200:
        schema_info = response.json()
        print(f"Schema successfully registered!")
        print(f"   Subject: {subject}")
        print(f"   Version: {schema_info['version']}")
        print(f"   Schema ID: {schema_info['id']}")
        print(f"\n   You can view it at:")
        print(f"   {SCHEMA_REGISTRY_URL}/subjects/{subject}/versions/{schema_info['version']}")
    else:
        print(f"Schema not found (this shouldn't happen!)")
        print(f"   Response: {response.text}")


if __name__ == "__main__":
    print("=" * 80)
    print("Kafka Avro Producer - Automatic Schema Registration Demo")
    print("=" * 80)
    print()
    
    # Create producer with Avro serialization
    producer, avro_serializer = create_producer_with_avro()
    
    # Produce sample transactions
    # The first message will automatically register the schema!
    produce_sample_transactions(producer, avro_serializer, num_messages=5)
    
    # Verify schema was registered
    verify_schema_registration()
    
    print("\n" + "=" * 80)
    print("Demo completed successfully!")
    print("=" * 80)
