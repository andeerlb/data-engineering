from __future__ import annotations

from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.datasets import Dataset
import pendulum
from datetime import timedelta
import random


# Dataset definition
# This represents a logical data asset, not a physical file
processed_data_dataset = Dataset("dataset://example/processed_data")


# Default arguments applied to all tasks
default_args = {
    "owner": "airflow",
    "retries": 2,
    "retry_delay": timedelta(seconds=10),
}

def capture_data(**context):
    """
    Simulates data ingestion from an external source
    (API, database, message queue, etc.)

    The returned value WILL be pushed to XCom automatically.
    """
    data = [random.randint(1, 100) for _ in range(5)]
    print(f"Captured data: {data}")

    # Returning a value automatically pushes it to XCom
    return data


def process_data(**context):
    """
    Pulls data from XCom, processes it and pushes
    the result back to XCom.
    """
    ti = context["ti"]

    # Explicit XCom pull from the previous task
    data = ti.xcom_pull(task_ids="capture_data")

    total = sum(data)
    avg = total / len(data)

    result = {
        "total": total,
        "average": avg,
        "count": len(data),
    }

    print(f"Processed result: {result}")

    # Returning a value pushes a new XCom entry
    return result


def save_result(**context):
    """
    Simulates persisting the processed result.
    This task publishes a Dataset update.
    """
    ti = context["ti"]
    result = ti.xcom_pull(task_ids="process_data")

    print(f"Saving result: {result}")

    # Here you would normally:
    # - insert into a database
    # - upload to S3
    # - send to an API
    # - publish to Kafka


with DAG(
    dag_id="example_pythonoperator_with_datasets",
    description="Example DAG using PythonOperator, XCom and Datasets",
    default_args=default_args,
    start_date=pendulum.now("UTC").subtract(days=1),
    schedule="@daily",
    catchup=False,
    tags=["example", "pythonoperator", "datasets"],
) as dag:

    capture_data_task = PythonOperator(
        task_id="capture_data",
        python_callable=capture_data,
    )

    process_data_task = PythonOperator(
        task_id="process_data",
        python_callable=process_data,
    )

    save_result_task = PythonOperator(
        task_id="save_result",
        python_callable=save_result,
        outlets=[processed_data_dataset],  # Dataset is emitted here
    )

    # Task dependencies
    capture_data_task >> process_data_task >> save_result_task
