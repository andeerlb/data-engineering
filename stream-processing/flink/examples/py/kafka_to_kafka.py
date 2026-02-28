"""
Apache Flink - Kafka to Kafka Pipeline
=======================================
Complete pipeline that reads from a Kafka topic, transforms the data,
and writes to another Kafka topic.

Prerequisites:
- Kafka running: cd ../kafka && docker-compose up -d
- Flink running: docker-compose up -d
- Topics 'input-topic' and 'output-topic' created
- apache-flink and apache-flink-libraries installed
"""

from pyflink.datastream import StreamExecutionEnvironment
from pyflink.datastream.connectors.kafka import (
    KafkaSource, 
    KafkaOffsetsInitializer,
    KafkaSink,
    KafkaRecordSerializationSchema
)
from pyflink.common.serialization import SimpleStringSchema
from pyflink.common.typeinfo import Types
import json


def create_kafka_pipeline():
    """
    Pipeline that reads from 'input-topic', processes, and writes to 'output-topic'.
    """
    # Create execution environment
    env = StreamExecutionEnvironment.get_execution_environment()
    env.set_parallelism(1)
    
    # Configure Kafka source (input)
    kafka_source = KafkaSource.builder() \
        .set_bootstrap_servers("kafka:29092") \
        .set_topics("input-topic") \
        .set_group_id("flink-pipeline-group") \
        .set_starting_offsets(KafkaOffsetsInitializer.earliest()) \
        .set_value_only_deserializer(SimpleStringSchema()) \
        .build()
    
    # Create input stream
    input_stream = env.from_source(
        kafka_source,
        watermark_strategy=None,
        source_name="Kafka Input"
    )
    
    # Process data
    def process_message(msg):
        """
        Example transformation: converts to JSON and adds timestamp
        """
        try:
            data = json.loads(msg)
        except:
            data = {"raw_message": msg}
        
        data["processed"] = True
        data["uppercase"] = msg.upper()
        
        return json.dumps(data)
    
    processed_stream = input_stream.map(
        process_message, 
        output_type=Types.STRING()
    )
    
    # Configure Kafka sink (output)
    kafka_sink = KafkaSink.builder() \
        .set_bootstrap_servers("kafka:29092") \
        .set_record_serializer(
            KafkaRecordSerializationSchema.builder()
                .set_topic("output-topic")
                .set_value_serialization_schema(SimpleStringSchema())
                .build()
        ) \
        .build()
    
    # Write to Kafka
    processed_stream.sink_to(kafka_sink)
    
    # Also print for debugging
    processed_stream.print()
    
    # Execute the job
    env.execute("Kafka to Kafka Pipeline")


def setup_instructions():
    """
    Prints setup instructions.
    """
    print("=" * 60)
    print("Apache Flink - Kafka to Kafka Pipeline")
    print("=" * 60)
    print("\n1. Make sure Kafka is running:")
    print("   cd ../kafka && docker-compose up -d")
    
    print("\n2. Create the required topics:")
    print("   docker exec -it kafka kafka-topics --create \\")
    print("     --topic input-topic --bootstrap-server localhost:9092 \\")
    print("     --partitions 1 --replication-factor 1")
    print()
    print("   docker exec -it kafka kafka-topics --create \\")
    print("     --topic output-topic --bootstrap-server localhost:9092 \\")
    print("     --partitions 1 --replication-factor 1")
    
    print("\n3. Produce test messages to input-topic:")
    print("   docker exec -it kafka kafka-console-producer \\")
    print("     --topic input-topic --bootstrap-server localhost:9092")
    
    print("\n4. Consume messages from output-topic (in another terminal):")
    print("   docker exec -it kafka kafka-console-consumer \\")
    print("     --topic output-topic --bootstrap-server localhost:9092 \\")
    print("     --from-beginning")
    
    print("\n5. Run this script:")
    print("   python kafka_to_kafka.py")
    print("=" * 60)
    print()


if __name__ == '__main__':
    setup_instructions()
    
    response = input("Do you want to start the pipeline? (y/n): ")
    if response.lower() == 'y':
        print("\nStarting Kafka to Kafka pipeline...")
        create_kafka_pipeline()
    else:
        print("Pipeline not started.")
