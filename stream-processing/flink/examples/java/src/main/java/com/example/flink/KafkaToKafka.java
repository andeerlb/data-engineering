package com.example.flink;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ObjectNode;
import org.apache.flink.api.common.eventtime.WatermarkStrategy;
import org.apache.flink.api.common.serialization.SimpleStringSchema;
import org.apache.flink.connector.base.DeliveryGuarantee;
import org.apache.flink.connector.kafka.sink.KafkaRecordSerializationSchema;
import org.apache.flink.connector.kafka.sink.KafkaSink;
import org.apache.flink.connector.kafka.source.KafkaSource;
import org.apache.flink.connector.kafka.source.enumerator.initializer.OffsetsInitializer;
import org.apache.flink.streaming.api.datastream.DataStream;
import org.apache.flink.streaming.api.environment.StreamExecutionEnvironment;

/**
 * Kafka to Kafka Pipeline
 * 
 * Complete pipeline that:
 * 1. Reads from Kafka topic (source-topic)
 * 2. Transforms the data
 * 3. Writes to Kafka topic (sink-topic)
 * 
 * Prerequisites:
 * - Kafka must be running
 * - Topics 'source-topic' and 'sink-topic' must exist
 * 
 * Create topics:
 * docker exec -it kafka kafka-topics --create \
 *   --topic source-topic --bootstrap-server localhost:9092 \
 *   --partitions 3 --replication-factor 1
 * 
 * docker exec -it kafka kafka-topics --create \
 *   --topic sink-topic --bootstrap-server localhost:9092 \
 *   --partitions 3 --replication-factor 1
 * 
 * Test:
 * # Producer
 * docker exec -it kafka kafka-console-producer \
 *   --topic source-topic --bootstrap-server localhost:9092
 * 
 * # Consumer
 * docker exec -it kafka kafka-console-consumer \
 *   --topic sink-topic --bootstrap-server localhost:9092 \
 *   --from-beginning
 */
public class KafkaToKafka {

    private static final ObjectMapper objectMapper = new ObjectMapper();

    public static void main(String[] args) throws Exception {
        // 1. Create execution environment
        final StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();

        // 2. Configure Kafka source
        KafkaSource<String> source = KafkaSource.<String>builder()
            .setBootstrapServers("kafka:29092")
            .setTopics("source-topic")
            .setGroupId("flink-pipeline-group")
            .setStartingOffsets(OffsetsInitializer.earliest())
            .setValueOnlyDeserializer(new SimpleStringSchema())
            .build();

        // 3. Create input stream
        DataStream<String> inputStream = env.fromSource(
            source,
            WatermarkStrategy.noWatermarks(),
            "Kafka Source"
        );

        // 4. Transform the data
        DataStream<String> processedStream = inputStream
            .map(message -> {
                try {
                    // Try to parse as JSON
                    JsonNode jsonNode = objectMapper.readTree(message);
                    ObjectNode outputNode = objectMapper.createObjectNode();
                    
                    // Copy original fields
                    outputNode.setAll((ObjectNode) jsonNode);
                    
                    // Add processing metadata
                    outputNode.put("processed", true);
                    outputNode.put("processedAt", System.currentTimeMillis());
                    outputNode.put("uppercase", message.toUpperCase());
                    
                    return objectMapper.writeValueAsString(outputNode);
                } catch (Exception e) {
                    // If not JSON, create a simple JSON structure
                    ObjectNode outputNode = objectMapper.createObjectNode();
                    outputNode.put("raw_message", message);
                    outputNode.put("processed", true);
                    outputNode.put("processedAt", System.currentTimeMillis());
                    outputNode.put("uppercase", message.toUpperCase());
                    
                    return objectMapper.writeValueAsString(outputNode);
                }
            })
            .name("Transform");

        // Also print for debugging
        processedStream.print("Processed");

        // 5. Configure Kafka sink
        KafkaSink<String> sink = KafkaSink.<String>builder()
            .setBootstrapServers("kafka:29092")
            .setRecordSerializer(
                KafkaRecordSerializationSchema.builder()
                    .setTopic("sink-topic")
                    .setValueSerializationSchema(new SimpleStringSchema())
                    .build()
            )
            .setDeliveryGuarantee(DeliveryGuarantee.AT_LEAST_ONCE)
            .build();

        // 6. Write to Kafka
        processedStream.sinkTo(sink).name("Kafka Sink");

        // 7. Execute the job
        env.execute("Kafka to Kafka Pipeline");
    }
}
