from __future__ import annotations

from airflow.decorators import dag, task
import pendulum
from datetime import timedelta
import random

default_args = {
    "owner": "airflow",
    "retries": 2,
    "retry_delay": timedelta(seconds=10),
}

@dag(
    dag_id="example_taskflow_pipeline",
    description="Example DAG using TaskFlow API",
    default_args=default_args,
    start_date=pendulum.now("UTC").subtract(days=1),
    schedule="@daily",
    catchup=False,
    tags=["example", "taskflow"],
)
def example_taskflow_pipeline():
    """
    Simple DAG with a real pipeline structure.
    """

    @task
    def capture_data() -> list[int]:
        """
        Simulates capturing external data
        (API, database, queue, etc.)
        """
        data = [random.randint(1, 100) for _ in range(5)]
        print(f"Captured data: {data}")
        return data  # ← this automatically becomes XCom

    @task
    def process_data(data: list[int]) -> dict:
        """
        Processes the captured data
        """
        total = sum(data)
        avg = total / len(data)

        result = {
            "total": total,
            "average": avg,
            "count": len(data),
        }

        print(f"Processing result: {result}")
        return result

    @task
    def save_result(result: dict) -> None:
        """
        Simulates saving the result somewhere
        """
        print(f"Saving result: {result}")
        # here could be:
        # - INSERT into Postgres
        # - PUT to S3
        # - API call
        # - send to Kafka

    # Orchestration
    # The output of one task can be directly used as the input of another,
    # without needing to manually handle XComs.
    # The vantage of this approach is that it is more readable and less error-prone,
    # as you don't have to worry about task_ids or XCom keys.
    # The downside is that it is less flexible, as you cannot easily pull data from
    # arbitrary tasks or push intermediate results to XCom.
    # In general, TaskFlow is recommended for most use cases, while manual XCom handling is useful for more complex scenarios.
    # If you need to do more complex data passing, you can still use XComs inside TaskFlow tasks.
    # For example, you could have a task that processes data and then pushes some metadata to XCom for another task to consume.
    # In this example, we keep it simple and just pass data through function arguments and return values.
    # This is the recommended way to use TaskFlow, as it keeps the code clean and easy to understand.
    raw_data = capture_data()
    processed = process_data(raw_data)
    save_result(processed)


# To instantiate the DAG
example_taskflow_pipeline()
