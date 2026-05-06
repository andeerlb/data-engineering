# Apache Pulsar
![apache pulsar ui](./ui.png)

## What is Apache Pulsar?

[Apache Pulsar](https://pulsar.apache.org/) is a cloud-native, distributed messaging and streaming platform designed for high-throughput, low-latency workloads. It supports both publish-subscribe and message queue semantics, making it suitable for a wide range of real-time data processing scenarios. Pulsar is highly scalable, supports multi-tenancy, and provides strong durability guarantees.

**Key Features:**
- Multi-tenant architecture
- Seamless scalability (horizontally scalable)
- Low latency and high throughput
- Built-in support for geo-replication
- Tiered storage
- Native support for both streaming and queueing use cases

## Messaging
Pulsar is built on the pub-sub pattern. In this pattern, producers publish messages to topics; consumers subscribe to those topics, process incoming messages, and send aknowledgemnts to the broker when processing is finished.  

![](pub-sub-pulsar.svg)

When a subscription is created, pulsar retains all messages, even if the consumer is disconnected. The retained messages are discarded only when a consumer acknowledges that all these messages are processed successfully.

Messages are the basic unit of pulsar. they are what producers publish to topics and what consumers then consume from topics.

## ACK (Acknowledgement)
A message ack is sent by a consumer to a broker after the consumer consumes a message successfully. Then, this consumed message will be permanently stored and deleted only after all the subscriptions have ack it.

For batch messages, you can enable batch index ack to avoid dispatching ack messages to the consumer. 

Messages can be ack in one of the following two ways:

- Being ack individually
   - the consumer ack each message and sends an ack request to the broker
- Being ack cumulatively
   - The consumer only ack the last message it received. All messages in the stream up to the provieded message are not redelivered to that consumer.

## Retry letter topic
It allows you to store the messages that failed to be consumed and retry consuming them later. You can customize the interval at which the messages are redelivered. Consumers on the original topic are automatically subscribed to the retry leetter topic as well. Once the  maxium number of retries has been reached, the unconsumed messages are moved to a dead letter topic for manual processing. The functionality of a retry letter topic is implemented by consumers.

![](retry-letter-topic.svg)

## Dead letter topic
Dead letter topic allows you continue messages consumption even when some messages are not consumed successfully. The messages that have failed to be consumed are stored in a specific topic, which is called the dead letter topic. The functionally of a dead letter topic is implemented by consumers. You can decide how to handle the messages in the dead letter topic.

## Compression
Messages compression can reduce message size by paying some cpu overhead. The pulsar client supports the following compression types.

- LZ4
- ZLIB
- ZSTD
- SNAPPY

Compression types are stored in the message metadada, so consumers can adopt different compression types automatically, as needed.

## Batching
When a batching is enabled, the producer accumulates and sends a batch of messages in a single request. The batch size is defined by the maxium number of messages and the maximum publish latency. Therefore, the backlog size represents the total number of batches instead of the total number of messages.

## Chunking
Message chunking enables pulsar to process large payload messages by splitting the message into chunks at the producer side and aggregating chunked messages at the consumer side.

With the chunk enabled, when the size of a message exzceeds the allowed maximum payload size, the workflow of message ins as follow:

1. The producer splits the original message into chunked messages and publishes them with chunked metadata to the broker separately and in order
2. The broker stores the chunked messages in one managed ledger in the same way as that of ordinary messages, and it uses the `chunkedmessagerate` parameter to record chunked message rate on the topic.
3. The consumer buffers the chunked messages and aggregates them into the receiver queue when it receives all the chunks of a message
4. The client consumes the aggreated message from the receiver queue.

## Configuration
```sh
docker compose up -d

# validate if it's ok
docker exec -it pulsar-manager curl http://pulsar:8080/admin/v2/clusters # -> ["standalone"]

# to create user
CSRF_TOKEN=$(curl http://localhost:7750/pulsar-manager/csrf-token)
curl \
   -H 'X-XSRF-TOKEN: $CSRF_TOKEN' \
   -H 'Cookie: XSRF-TOKEN=$CSRF_TOKEN;' \
   -H "Content-Type: application/json" \
   -X PUT http://localhost:7750/pulsar-manager/users/superuser \
   -d '{"name": "pulsar", "password": "pulsar", "description": "test", "email": "username@test.org"}'
# visit  http://localhost:9527, the created account is admin/apachepulsar
```

## UI
Add a new environment

- Environment name: what you want, maybe `test`, `standalone`, etc.
- Service URL: `http://pulsar:8080`
- Bookie URL: `pulsar://pulsar:6650`

## What is a Bookie in Apache Pulsar?

A **Bookie** comes from Apache BookKeeper and is responsible for **storing data on disk**.

> A storage node that persists messages in Apache Pulsar

## How Pulsar Works

Apache Pulsar is split into two main parts:

### 1. Broker
- Receives messages from producers
- Sends messages to consumers
- Handles communication

### 2. Bookie (Storage)
- Stores messages on disk
- Ensures durability
- Manages logs (called *ledgers*)