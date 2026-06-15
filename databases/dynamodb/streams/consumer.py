import boto3
import time
from boto3.dynamodb.types import TypeDeserializer

ENDPOINT = "http://localhost:8000"
TABLE_NAME = "orders"

dynamodb_client = boto3.client(
    "dynamodb",
    endpoint_url=ENDPOINT,
    region_name="us-east-1",
    aws_access_key_id="fake",
    aws_secret_access_key="fake",
)

streams_client = boto3.client(
    "dynamodbstreams",
    endpoint_url=ENDPOINT,
    region_name="us-east-1",
    aws_access_key_id="fake",
    aws_secret_access_key="fake",
)

_deserializer = TypeDeserializer()


def deserialize(raw: dict) -> dict:
    return {k: _deserializer.deserialize(v) for k, v in raw.items()}


def get_stream_arn() -> str:
    table = dynamodb_client.describe_table(TableName=TABLE_NAME)["Table"]
    arn = table.get("LatestStreamArn")
    if not arn:
        raise RuntimeError("Stream not enabled on this table — run `tofu apply` first.")
    return arn


def get_shard_iterators(stream_arn: str) -> list[str]:
    shards = streams_client.describe_stream(StreamArn=stream_arn)["StreamDescription"]["Shards"]
    iterators = []
    for shard in shards:
        iterator = streams_client.get_shard_iterator(
            StreamArn=stream_arn,
            ShardId=shard["ShardId"],
            ShardIteratorType="TRIM_HORIZON",
        )["ShardIterator"]
        iterators.append(iterator)
    return iterators


def print_record(record: dict) -> None:
    event = record["eventName"]
    keys = deserialize(record["dynamodb"]["Keys"])
    print(f"\n[{event}]  keys={keys}")

    if "OldImage" in record["dynamodb"]:
        old = deserialize(record["dynamodb"]["OldImage"])
        print(f"  BEFORE → {old}")

    if "NewImage" in record["dynamodb"]:
        new = deserialize(record["dynamodb"]["NewImage"])
        print(f"  AFTER  → {new}")


def poll(iterators: list[str]) -> None:
    print(f"Listening on {len(iterators)} shard(s)... (Ctrl+C to stop)\n")
    while iterators:
        next_iterators = []
        for iterator in iterators:
            response = streams_client.get_records(ShardIterator=iterator, Limit=100)
            for record in response.get("Records", []):
                print_record(record)
            next_iter = response.get("NextShardIterator")
            if next_iter:
                next_iterators.append(next_iter)
        iterators = next_iterators
        time.sleep(1)
    print("\nAll shards closed.")


def main() -> None:
    stream_arn = get_stream_arn()
    print(f"Stream ARN: {stream_arn}")
    iterators = get_shard_iterators(stream_arn)
    poll(iterators)


if __name__ == "__main__":
    main()
