"""
Apache Flink - Kafka Consumer Example
======================================
Example of reading data from a Kafka topic using PyFlink.

Prerequisites:
- Kafka running: cd ../kafka && docker-compose up -d
- Flink running: docker-compose up -d
- Topic 'input-topic' created
- apache-flink-libraries installed
"""

from pyflink.datastream import StreamExecutionEnvironment
from pyflink.datastream.connectors.kafka import KafkaSource, KafkaOffsetsInitializer
from pyflink.common.serialization import SimpleStringSchema
from pyflink.common.typeinfo import Types


def kafka_consumer_example():
    """
    Consumes messages from a Kafka topic and processes with Flink.
    """
    # Create execution environment
    env = StreamExecutionEnvironment.get_execution_environment()
    env.set_parallelism(1)
    
    # Add Kafka connector JAR (required for PyFlink)
    # env.add_jars("file:///path/to/flink-sql-connector-kafka.jar")
    
    # Configure Kafka source
    kafka_source = KafkaSource.builder() \
        .set_bootstrap_servers("kafka:29092") \
        .set_topics("input-topic") \
        .set_group_id("flink-consumer-group") \
        .set_starting_offsets(KafkaOffsetsInitializer.earliest()) \
        .set_value_only_deserializer(SimpleStringSchema()) \
        .build()
    
    # Create stream from Kafka
    data_stream = env.from_source(
        kafka_source,
        watermark_strategy=None,
        source_name="Kafka Source"
    )
    
    # Process data
    processed = data_stream \
        .map(lambda msg: f"Processed: {msg.upper()}", output_type=Types.STRING())
    
    # Print result
    processed.print()
    
    # Execute the job
    env.execute("Kafka Consumer Example")


if __name__ == '__main__':
    print("Starting Kafka consumer with Flink...")
    print("Make sure Kafka is running (cd ../kafka && docker-compose up -d)")
    print("and the topic 'input-topic' exists.")
    print("\nTo create the topic:")
    print("docker exec -it kafka kafka-topics --create --topic input-topic --bootstrap-server localhost:9092 --partitions 1 --replication-factor 1")
    print("\nTo produce test messages:")
    print("docker exec -it kafka kafka-console-producer --topic input-topic --bootstrap-server localhost:9092")
    print()
    
    kafka_consumer_example()
