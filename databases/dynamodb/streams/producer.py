import boto3
import time
from datetime import datetime, timezone

ENDPOINT = "http://localhost:8000"

dynamodb = boto3.resource(
    "dynamodb",
    endpoint_url=ENDPOINT,
    region_name="us-east-1",
    aws_access_key_id="fake",
    aws_secret_access_key="fake",
)

table = dynamodb.Table("orders")

ORDER_ID = "order-001"
CREATED_AT = datetime.now(timezone.utc).isoformat()


def main():
    print("=== INSERT ===")
    table.put_item(
        Item={
            "order_id": ORDER_ID,
            "created_at": CREATED_AT,
            "user_id": "user-42",
            "status": "PENDING",
            "total": "150.00",
        }
    )
    print(f"Inserted {ORDER_ID} with status=PENDING")
    time.sleep(2)

    print("\n=== UPDATE ===")
    table.update_item(
        Key={"order_id": ORDER_ID, "created_at": CREATED_AT},
        UpdateExpression="SET #s = :s",
        ExpressionAttributeNames={"#s": "status"},
        ExpressionAttributeValues={":s": "SHIPPED"},
    )
    print(f"Updated {ORDER_ID} → status=SHIPPED")
    time.sleep(2)

    print("\n=== DELETE ===")
    table.delete_item(Key={"order_id": ORDER_ID, "created_at": CREATED_AT})
    print(f"Deleted {ORDER_ID}")


if __name__ == "__main__":
    main()
