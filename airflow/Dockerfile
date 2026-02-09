FROM apache/airflow:slim-latest-python3.13

USER root
# install dependencies for vim and clean up apt cache to reduce image size
RUN apt-get update && apt-get install -y \
    vim \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
USER airflow
# copy requirements.txt to the container and install dependencies
COPY requirements.txt /requirements.txt
RUN pip install --no-cache-dir -r /requirements.txt
# create necessary directories
RUN mkdir -p /opt/airflow/dags/configs