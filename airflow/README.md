### first dag execution graph
![alt text](./assets/image.png)

### Commands
Run to execute airflow locally
`docker compose up`

Save your dags here to edit and be importated by airflow
```
vim dags/**
```

To get the admin password
`docker compose logs airflow-webserver | grep Password`