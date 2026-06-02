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
