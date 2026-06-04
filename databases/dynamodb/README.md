# DynamoDB Local

Local DynamoDB environment using Docker and Terraform.

- DynamoDB Local | http://localhost:8000 (api)
- DynamoDB Admin | http://localhost:8001 (web ui)

![alt text](image.png)
![alt text](image-1.png)

### Start the containers

```bash
docker compose up -d
```

### Provision tables with Terraform

```bash
cd terraform
tofu init
tofu plan
tofu apply -auto-approve
```

This creates two example tables:
- **users** — partition key: `user_id` (String)
- **orders** — partition key: `order_id` (String), 
  - sort key: `created_at` (String), 
  - GSI on `user_id`

### Verify tables were created

```bash
aws dynamodb list-tables \
  --endpoint-url http://localhost:8000 \
  --region us-east-1 \
  --no-sign-request
```

## Usage Examples

### Put an item

```bash
aws dynamodb put-item \
  --endpoint-url http://localhost:8000 \
  --region us-east-1 \
  --no-sign-request \
  --table-name users \
  --item '{"user_id": {"S": "u1"}, "name": {"S": "Alice"}}'
```

### Get an item

```bash
aws dynamodb get-item \
  --endpoint-url http://localhost:8000 \
  --region us-east-1 \
  --no-sign-request \
  --table-name users \
  --key '{"user_id": {"S": "u1"}}'
```

### Scan a table

```bash
aws dynamodb scan \
  --endpoint-url http://localhost:8000 \
  --region us-east-1 \
  --no-sign-request \
  --table-name users
```

## Tear Down

```bash
cd terraform && tofu destroy -auto-approve
```

```bash
docker compose down
# To also delete persisted data:
docker compose down -v
```

## What s dynamodb?
IS a serverless, fully managed, distributted nosql database with single-digit millisecond performance at any scale.


### Serverless
You don't need to provision any servers, or pattch, omanage, install, maintain, or operate any software. Zero downtime maintenance. There are no maintenance windows.

On demand capacity mode offers pay-as-you-go pricing for read and write requests so you only pay for what you use. With on demand, dynamo instatly scales up or down your tables to adjust for capacity and maintains performance with zero administration. Itt also scales down to zero so you don't pay for throughput when your table doesn't have traffic and there are no cold starts.

### NoSQL
As a NoSQL database, it was purpose built to deliver improved performance, scalablity, manageability, and flexbility compared to traditional relational databases. To support a wide variety of use cases, Dynamodb supports both key value and document data models.

Unlike relational databases, dynamodb doesn't support a join operator. We recommend that you denormalize your data model to reduce database round trips and processing power needed tto answer queries. As nosql database, dynamodb provides strong read consistency and ACID transactions to build entterprise-grade applications.

### fully managed
As a fully managed db service, it handles the undifferentiated heavy lifting of manageing a database so that you can focus on building value for your customers. It handles setup, configurations, and maintenance, high availablility, hward provisioning, security, backups, monitoring, and more. 

## Capabilities of this db

### Multi-active replication with global tables
Global tables provide multi-active replicattion of your data across your chosen AWS regions witth 99.999% availability.
Global tables deliver a fully managed solution for deploying a multi-region, multi-active database, without building and maintaning your own replication solution.

### ACID transactions