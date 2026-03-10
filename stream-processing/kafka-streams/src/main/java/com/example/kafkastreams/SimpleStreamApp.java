package com.example.kafkastreams;

import org.apache.kafka.common.serialization.Serdes;
import org.apache.kafka.streams.KafkaStreams;
import org.apache.kafka.streams.StreamsBuilder;
import org.apache.kafka.streams.StreamsConfig;
import org.apache.kafka.streams.Topology;
import org.apache.kafka.streams.errors.StreamsUncaughtExceptionHandler;
import org.apache.kafka.streams.kstream.KStream;

import java.net.InetSocketAddress;
import java.net.Socket;
import java.util.Properties;
import java.util.concurrent.CountDownLatch;

public class SimpleStreamApp {

    static void main(String[] args) {
        // Input topic receives raw text messages.
        final String inputTopic = "orders-input";

        // Output topic receives transformed messages.
        final String outputTopic = "orders-output";

        // Check broker connectivity before starting Kafka Streams.
        // This avoids the endless rebootstrap log spam when the broker is unreachable.
        try (Socket socket = new Socket()) {
            socket.connect(new InetSocketAddress("localhost", 9092), 3000);
        } catch (Exception e) {
            System.err.println("[ERROR] Cannot connect to Kafka broker. Aborting.");
            System.exit(1);
        }
        // Streams properties define app identity, broker address, and default serializers.
        final Properties props = buildProps();

        // StreamsBuilder is the entry point to define the processing topology.
        // Topology is immutable and thread-safe, while StreamsBuilder is mutable and not thread-safe.
        // You can use multiple StreamsBuilder instances to build different topologies in the same app.
        // However, you cannot share a StreamsBuilder across multiple KafkaStreams instances.
        // For simplicity, we use a single StreamsBuilder and KafkaStreams instance in this app.
        final StreamsBuilder builder = new StreamsBuilder();

        // Read records from the input topic as a KStream.
        final KStream<String, String> source = builder.stream(inputTopic);

        // Processing steps:
        // 1) Ignore empty values.
        // 2) Trim spaces.
        // 3) Convert text to upper case.
        // Processing occurs record by record, and the order of records is preserved within each partition.
        // Note that the processing is stateless, so we don't need to worry about state stores or fault tolerance in this simple example.
        // In a real app, you would likely have more complex processing logic, possibly with stateful operations (e.g., aggregations, joins) and error handling (e.g., dead letter queues).
        // Also, keep in mind that the processing is distributed across multiple stream threads, so you should avoid shared mutable state and ensure thread safety if you use any external resources (e.g., databases, APIs).
        final KStream<String, String> transformed = source
                .filter((_, val) -> val != null && !val.isBlank())
                .mapValues(String::trim)
                .mapValues(val -> val.toUpperCase());

        // Write transformed records to the output topic.
        // The output topic will have the same key and value types as the input topic (String, String) because we didn't change the key type and we used mapValues which preserves the key.
        transformed.to(outputTopic);

        // Build an immutable topology and print it for quick debugging.
        final Topology topology = builder.build();
        System.out.println("=== TOPOLOGY DESCRIPTION ===");
        System.out.println(topology.describe());

        // Create and start the Kafka Streams runtime.
        final KafkaStreams streams = new KafkaStreams(topology, props);

        // Use a CountDownLatch to block the main thread until the app is shut down, either by an error or by an interrupt signal (Ctrl+C).
        final CountDownLatch latch = new CountDownLatch(1);

        // Shut down the application if Kafka Streams enters ERROR state.
        streams.setStateListener((newState, oldState) -> {
            if (newState == KafkaStreams.State.ERROR) {
                System.err.println("[ERROR] Kafka Streams entered ERROR state (previous: " + oldState + "). Shutting down...");
                latch.countDown();
            }
        });

        // Shut down the application on any uncaught exception in a stream thread.
        streams.setUncaughtExceptionHandler(exception -> {
            System.err.println("[ERROR] Uncaught exception in Kafka Streams: " + exception.getMessage());
            return StreamsUncaughtExceptionHandler.StreamThreadExceptionResponse.SHUTDOWN_APPLICATION;
        });

        // Close the app gracefully when the process is interrupted (Ctrl+C).
        Runtime.getRuntime().addShutdownHook(new Thread(() -> {
            streams.close();
            latch.countDown();
        }));

        streams.start();

        // Block the main thread until the app is shut down.
        try {
            latch.await();
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        } finally {
            streams.close();
        }
    }

    private static Properties buildProps() {
        final Properties props = new Properties();
        props.put(StreamsConfig.APPLICATION_ID_CONFIG, "simple-stream-app");
        props.put(StreamsConfig.BOOTSTRAP_SERVERS_CONFIG, "localhost:9092");
        props.put(StreamsConfig.DEFAULT_KEY_SERDE_CLASS_CONFIG, Serdes.StringSerde.class.getName());
        props.put(StreamsConfig.DEFAULT_VALUE_SERDE_CLASS_CONFIG, Serdes.StringSerde.class.getName());

        // Fail fast when broker is unreachable: no retries, short timeouts (~3s total).
        props.put(StreamsConfig.adminClientPrefix("retries"), "0");
        props.put(StreamsConfig.adminClientPrefix("retry.backoff.ms"), "500");
        props.put(StreamsConfig.adminClientPrefix("request.timeout.ms"), "3000");
        props.put(StreamsConfig.adminClientPrefix("connections.max.idle.ms"), "3000");
        props.put(StreamsConfig.adminClientPrefix("metadata.max.age.ms"), "1000");

        return props;
    }
}
