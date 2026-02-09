# first dag execution graph
![alt text](./assets/image.png)

# 1. Edit locally your Dags
```
vim dags/**
vim dags/configs/pipelines.yaml
```
# 2. The scheduler will automatically detected your changes (~30s)
# Or you might force the update
`docker compose restart airflow-scheduler`
# 3. Look at the logs if needed
`docker compose logs -f airflow-scheduler`