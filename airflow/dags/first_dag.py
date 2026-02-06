# This code defines a DAG (Directed Acyclic Graph) in Apache Airflow, which is a platform used to programmatically author, schedule, and monitor workflows. The DAG is named "my_first_dag" and it is set to start on January 1, 2023. The DAG is scheduled to run every hour at the 30th minute (e.g., 12:30, 1:30, 2:30, etc.) and it will not backfill any past intervals when it is first created.
from airflow import DAG
# operators are the building blocks of a DAG, and they define the tasks that will be executed.
# PythonOperator, which allows us to execute a Python function as a task in our DAG.
# BranchPythonOperator, which allows us to define a task that can branch to different tasks based on a condition
from airflow.operators.python import PythonOperator, BranchPythonOperator
# BashOperator, which allows us to execute a bash command as a task in our DAG.
from airflow.operators.bash import BashOperator
# pandas is a popular data manipulation library in Python, and it is commonly used in data engineering and data science workflows. In this code, we import pandas as pd, which allows us to use the pandas library with the alias "pd". However, in this specific code snippet, we do not actually use pandas, so it is not necessary to import it. You can remove the import statement if you do not need to use pandas in your DAG.
import pandas as pd
# requests is a popular library in Python for making HTTP requests. It allows you to send HTTP requests and handle responses in a simple and intuitive way. In this code, we import the requests library, but we do not actually use it in the code snippet provided. If you do not need to make any HTTP requests in your DAG, you can remove the import statement for requests.
import requests
# datetime is a module in Python that provides classes for manipulating dates and times. In this code, we import the datetime class from the datetime module, which allows us to work with dates and times in our DAG. We use the datetime class to set the start date for our DAG, which is required for the DAG to run. The start date should be a datetime object, and in this case, we set it to January 1, 2023.
from datetime import datetime
# json is a module in Python that provides functions for working with JSON (JavaScript Object Notation) data. It allows you to parse JSON strings and convert them into Python objects, as well as convert Python objects into JSON strings. In this code, we import the json module, but we do not actually use it in the code snippet provided. If you do not need to work with JSON data in your DAG, you can remove the import statement for json.
import json 

def capture_and_count_data():
    print("Capturing and counting data...")
    url = "https://jsonplaceholder.typicode.com/posts"
    response = requests.get(url)
    if response.status_code == 200:
        # DataFrame is a 2-dimensional labeled data structure in pandas that can hold data of different types (e.g., integer, float, string). It is similar to a table in a relational database or an Excel spreadsheet. The pd.DataFrame() constructor is used to create a DataFrame object from various data sources, such as lists, dictionaries, or in this case, JSON data. In this code, we use pd.DataFrame() to create a DataFrame from the JSON response content obtained from the API endpoint "https://jsonplaceholder.typicode.com/posts". The json.load() function is used to parse the JSON content and convert it into a Python object, which is then passed to the pd.DataFrame() constructor to create the DataFrame. The resulting DataFrame will have columns corresponding to the keys in the JSON data and rows corresponding to each item in the JSON array. We then calculate the number of rows in the DataFrame using len(df.index) and return that count as the result of the function.
        # pd.DataFrame() is a constructor in the pandas library that is used to create a DataFrame object. A DataFrame is a two-dimensional, size-mutable, and potentially heterogeneous tabular data structure with labeled axes (rows and columns). It is one of the most commonly used data structures in pandas for data manipulation and analysis. In this code, we use pd.DataFrame() to create a DataFrame from the JSON response content obtained from the API endpoint "https://jsonplaceholder.typicode.com/posts". The json.load() function is used to parse the JSON content and convert it into a Python object, which is then passed to the pd.DataFrame() constructor to create the DataFrame.
        # We use the json module to parse the JSON response content and convert it into a pandas DataFrame. The json.load() function is used to parse the JSON content, and then we pass the parsed data to the pd.DataFrame() constructor to create a DataFrame. The resulting DataFrame will have columns corresponding to the keys in the JSON data and rows corresponding to each item in the JSON array.
        df = pd.DataFrame(json.load(response.content)) # we are using response.content to get the raw content of the response, which is in bytes. The json.load() function is used to parse the JSON content and convert it into a Python object, which is then passed to the pd.DataFrame() constructor to create the DataFrame. The resulting DataFrame will have columns corresponding to the keys in the JSON data and rows corresponding to each item in the JSON array.
        # Calculate the number of rows in the DataFrame using len(df.index) and return that count as the result of the function.
        qtd = len(df.index) # we are using index here, because it is a property of the DataFrame that returns the row labels of the DataFrame. The len() function is used to calculate the number of rows in the DataFrame by counting the number of elements in the index. This gives us the total number of rows in the DataFrame, which is then stored in the variable qtd and returned as the result of the function.
        return qtd
    else:
        print(f"Failed to fetch data. Status code: {response.status_code}")

# ti is an abbreviation for "task instance" in Airflow. It is an object that represents a specific instance of a task being executed within a DAG run. The task instance contains information about the task, such as its state, execution date, and any XCom (cross-communication) data that may have been passed between tasks.
def verify_task_is_valid(ti):
    # xcom_pull is a method of the task instance (ti) that allows you to retrieve data that has been pushed to XCom (cross-communication) by other tasks in the DAG. In this code, we use ti.xcom_pull() to retrieve the value that was returned by the "capture_and_count_data" task. The task_ids parameter is used to specify the task from which we want to pull the data.
    qtd = ti.xcom_pull(task_ids="capture_and_count_data")
    if (qtd > 100):
        return "valid"
    else:
        return "non_valid"

# start date is required for the DAG to run, and it should be a datetime object. In this case, we set it to January 1, 2023.
# the DAG will run every day at midnight by default
# the dag will start running from the start date and will continue to run according to the schedule interval until it is stopped or deleted. If the start date is in the past, the DAG will backfill and run for all intervals from the start date until the current date, unless catchup is set to False.

# schedule_interval is a cron expression that defines how often the DAG should run. In this case, it is set to "30 * * * *", which means the DAG will run every hour at the 30th minute (e.g., 12:30, 1:30, 2:30, etc.).
# The cron expression is in the format of "minute hour day_of_month month day_of_week". In this case, the minute is set to 30, and the other fields are set to "*" which means any value.
# For example, if you want the DAG to run every day at 2:00 AM, you would set the schedule_interval to "0 2 * * *".
# If you want the DAG to run every Monday at 8:00 AM, you would set the schedule_interval to "0 8 * * 1".
# For more information on cron expressions, you can refer to the Airflow documentation: https://airflow.apache.org/docs/apache-airflow/stable/scheduler.html#cron-expressions

# catchup is a parameter that determines whether the DAG should run for all past scheduled intervals when it is first created. If catchup is set to True, the DAG will run for all past intervals from the start date until the current date. If catchup is set to False, the DAG will only run for the current interval and will not backfill any past intervals. In this case, we set catchup to False, which means the DAG will only run for the current interval and will not backfill any past intervals.
# For example, if you set the start date to January 1, 2023, and the current date is January 10, 2023, and catchup is set to True, the DAG will run for all intervals from January 1 to January 10. If catchup is set to False, the DAG will only run for the current interval (January 10) and will not backfill any past intervals.
# For more information on catchup, you can refer to the Airflow documentation: https://airflow.apache.org/docs/apache-airflow/stable/concepts/dags.html#catchup
with DAG(dag_id="my_first_dag", start_date=datetime(2023, 1, 1),
    schedule="30 * * * *", catchup=False) as dag:

    capture_and_count_data_task = PythonOperator(
        # task_id is a unique identifier for the task within the DAG. It is used to reference the task in other parts of the DAG, such as when defining dependencies between tasks. In this case, we set the task_id to "capture_and_count_data".
        task_id="capture_and_count_data",
        # python_callable is a parameter that specifies the Python function that will be executed when the task runs. 
        # In this case, we set python_callable to capture_and_count_data, which means that the capture_and_count_data function will be executed when the "capture_and_count_data" task runs.
        python_callable=capture_and_count_data
    )

    # branchpythonoperator allows us to define a task that can branch to different tasks based on a condition. In this case, we define a task called "is_valid" that will execute the capture_and_count_data function and check if the result is greater than 100. If the result is greater than 100, it will branch to the "valid" task; otherwise, it will branch to the "non_valid" task.
    is_valid = BranchPythonOperator(
        task_id="is_valid",
        python_callable=verify_task_is_valid
    )

    valid = BashOperator(
        task_id="valid",
        bash_command="echo 'Quantity is valid (ok)'"
    )

    non_valid = BashOperator(
        task_id="non_valid",
        bash_command="echo 'Quantity is not valid (not ok)'"
    )

    # In Airflow, we define dependencies between tasks using the bitshift operators (>> and <<). 
    # The >> operator is used to indicate that one task should run after another task.
    # The << operator is used to indicate that one task should run before another task.
    # In this code, we define the dependencies between the tasks as follows:
    # The "capture_and_count_data" task should run before the "is_valid" task, and the "is_valid" task should run before both the "valid" and "non_valid" tasks. 
    # This means that the "capture_and_count_data" task will execute first, and once
    capture_and_count_data >> is_valid >> [valid, non_valid]

