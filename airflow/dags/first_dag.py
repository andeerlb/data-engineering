# This code defines a DAG (Directed Acyclic Graph) in Apache Airflow.
# Apache Airflow is a platform used to programmatically author, schedule,
# and monitor workflows (pipelines).

import pendulum
import requests

# In Airflow 3.x, the recommended way to define DAGs and tasks
# is using the TaskFlow API, which relies on decorators.
from airflow.decorators import dag, task

# BranchPythonOperator is still used when you need to decide
# which path the DAG should follow based on a condition.
from airflow.operators.python import BranchPythonOperator

# BashOperator allows us to execute bash commands as tasks in our DAG.
from airflow.operators.bash import BashOperator


# The @dag decorator is the modern (and recommended) way to define a DAG
# in Airflow 2.x and 3.x.
#
# start_date:
#   - Must be a timezone-aware datetime in Airflow 3.x
#   - Using pendulum avoids subtle bugs with timezones and scheduling
#
# schedule:
#   - A cron expression that defines how often the DAG should run
#   - "30 * * * *" means every hour at minute 30
#
# catchup:
#   - If False, Airflow will not backfill past runs
#
# tags:
#   - Used only for organization and filtering in the Airflow UI
@dag(
    dag_id="my_first_dag",
    start_date=pendulum.now("America/Sao_Paulo").subtract(days=1),
    schedule="30 * * * *",
    catchup=False,
    tags=["first", "taskflow", "example"],
)
def my_first_dag():

    # The @task decorator defines a task using the TaskFlow API.
    #
    # In TaskFlow:
    #   - The return value of the function is automatically pushed to XCom
    #   - No need to manually use ti.xcom_push or ti.xcom_pull
    #
    # The return type hint (-> int) is optional but recommended,
    # as it improves readability and helps static analysis tools.
    @task
    def capture_and_count_data() -> int:
        print("Capturing and counting data...")

        # We fetch data from a public API.
        # requests is a popular Python library for making HTTP requests.
        url = "https://jsonplaceholder.typicode.com/posts"
        # this line makes a GET request to the specified URL with a timeout of 30 seconds
        # the return is a list of posts in JSON format
        # [{ "userId": 1, "id": 1, "title": "", "body": "" }...]
        response = requests.get(url, timeout=30)

        # raise_for_status() will raise an exception if the HTTP
        # response code is not 2xx, causing the task to fail.
        response.raise_for_status()

        # Count items directly from the JSON array in the response.
        data = response.json()
        qtd = len(data)

        print(f"Quantidade de registros: {qtd}")

        # Returning a value in a TaskFlow task automatically
        # stores it in XCom.
        return qtd

    # This function contains the branching logic.
    #
    # It receives the value produced by the previous task
    # (automatically pulled from XCom by Airflow).
    #
    # The function must return:
    #   - the task_id of the next task to follow
    def branch_logic(qtd: int) -> str:
        if qtd > 100:
            return "valid"
        else:
            return "non_valid"

    # BranchPythonOperator decides which downstream task will run.
    #
    # op_args receives the output of capture_and_count_data(),
    # which is resolved by Airflow at runtime using XCom.
    is_valid = BranchPythonOperator(
        task_id="is_valid",
        python_callable=branch_logic,
        op_args=[capture_and_count_data()],
    )

    # BashOperator that runs if the quantity is considered valid.
    valid = BashOperator(
        task_id="valid",
        bash_command="echo 'Quantity is valid (ok)'",
    )

    # BashOperator that runs if the quantity is considered not valid.
    non_valid = BashOperator(
        task_id="non_valid",
        bash_command="echo 'Quantity is not valid (not ok)'",
    )

    # In Airflow, dependencies between tasks are defined
    # using bitshift operators:
    #
    # >> means "run after"
    #
    # In this DAG:
    #   - is_valid runs after capture_and_count_data
    #   - depending on the branch result, either "valid"
    #     or "non_valid" will run
    is_valid >> [valid, non_valid]


# Calling the function actually instantiates the DAG.
# Without this call, Airflow will not register the DAG.
my_first_dag()
