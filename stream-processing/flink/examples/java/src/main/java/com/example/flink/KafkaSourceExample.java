package com.example.flink;

import org.apache.flink.api.common.eventtime.WatermarkStrategy;
import org.apache.flink.api.common.serialization.SimpleStringSchema;
import org.apache.flink.connector.kafka.source.KafkaSource;
import org.apache.flink.connector.kafka.source.enumerator.initializer.OffsetsInitializer;
import org.apache.flink.streaming.api.datastream.DataStream;
import org.apache.flink.streaming.api.environment.StreamExecutionEnvironment;

/**
 * Kafka Source Example
 * 
 * Demonstrates how to consume data from Kafka topic.
 * 
 * Prerequisites:
 * - Kafka must be running
 * - Topic 'input-events' must exist
 * 
 * Create topic:
 * docker exec -it kafka kafka-topics --create \
 *   --topic input-events --bootstrap-server localhost:9092 \
 *   --partitions 3 --replication-factor 1
 */
public class KafkaSourceExample {

    public static void main(String[] args) throws Exception {
        // 1. Create execution environment
        final StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();

        // 2. Configure Kafka source
        KafkaSource<String> source = KafkaSource.<String>builder()
            // Kafka broker address (use internal hostname for container)
            .setBootstrapServers("kafka:29092")
            // Topic to consume from
            .setTopics("input-events")
            // Consumer group ID
            .setGroupId("flink-consumer-group")
            // Start from earliest available offset
            .setStartingOffsets(OffsetsInitializer.earliest())
            // Deserialize messages as strings
            .setValueOnlyDeserializer(new SimpleStringSchema())
            .build();

        // 3. Create data stream from Kafka
        DataStream<String> stream = env.fromSource(
            source,
            WatermarkStrategy.noWatermarks(),
            "Kafka Source"
        );

        // 4. Process messages
        DataStream<String> processed = stream
            .map(msg -> "Processed: " + msg.toUpperCase());

        // 5. Print results
        processed.print();

        // 6. Execute the job
        env.execute("Kafka Source Example");
    }
}
