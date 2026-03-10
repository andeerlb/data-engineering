# Kafka Streams Simple Example (Java 25 + Gradle)

This folder now contains a **simple Kafka Streams application** built with **Gradle** and **Java 25**.

## What This Example Does

The app reads text messages from `orders-input`, applies simple transformations, and writes results to `orders-output`:

1. Ignore null/blank values
2. Trim extra spaces
3. Convert text to uppercase

## Requirements

- Java 25 installed
- Gradle installed (or add a Gradle Wrapper later)
- Kafka running locally on `localhost:9092`

If you still need Kafka locally, use the setup in `../kafka/README.md`.

## Create Topics

```bash
kafka-topics --bootstrap-server localhost:9092 --create --topic orders-input --partitions 1 --replication-factor 1
kafka-topics --bootstrap-server localhost:9092 --create --topic orders-output --partitions 1 --replication-factor 1
```

## Run The Streams App

From this folder (`stream-processing/kafka-streams`):

```bash
gradle run
```

## Test The Flow

In terminal A, produce sample messages:

```bash
kafka-console-producer --bootstrap-server localhost:9092 --topic orders-input
```

Type a few values, for example:

```text
first order
second order
third order
```

In terminal B, consume transformed messages:

```bash
kafka-console-consumer --bootstrap-server localhost:9092 --topic orders-output --from-beginning
```

Expected output:

```text
FIRST ORDER
SECOND ORDER
THIRD ORDER
```
