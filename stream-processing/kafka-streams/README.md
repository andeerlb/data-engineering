# Kafka vs Kafka Streams

- **Apache Kafka** is a distributed event streaming platform (the infrastructure).
    - Look at the folder [kafka-folder](../kafka//README.md) to learn more about kafka
- **Kafka Streams** is a Java library to process data in Kafka topics (the application layer).

## When to Use Each

Use **Kafka** when you need:
- Decoupled communication between services
- Durable event storage and replay
- High-throughput, fault-tolerant event transport

Use **Kafka Streams** when you need:
- Real-time transformations (e.g., clean/enrich events)
- Stateful processing (counts, windows, sessionization)
- Stream-table or stream-stream joins directly in code

## Key Takeaway

You usually do **not** choose one *instead of* the other:
- You use **Kafka** as the event platform.
- You use **Kafka Streams** to build processing applications on top of Kafka.
