### first dag execution graph
![alt text](./assets/image.png)

### Commands
Run to execute airflow locally
`docker compose up`

Save your dags here to edit and be importated by airflow
```
vim dags/**
```

To get the admin password.  
`docker compose logs airflow-webserver | grep Password`

### Taskflow Vs Xcoms
TaskFlow is Airflow’s Python-first API where you define tasks with @task functions and pass data between them as normal return values. Airflow automatically stores those return values in XCom and wires dependencies for you.

XComs (cross-communications) are the underlying mechanism: a key/value store in the Airflow metadata DB used to pass small pieces of data between tasks.

Practical differences:

- TaskFlow hides XComs behind function returns and arguments, so code is cleaner.
- Classic operators + XComs require explicit ti.xcom_push() / ti.xcom_pull().
- Both end up using XComs under the hood; TaskFlow is just the nicer interface.
- Rule of thumb: use TaskFlow when your logic is Python and the data you pass is small; use explicit XComs when you need fine control or you’re mixing classic operators.