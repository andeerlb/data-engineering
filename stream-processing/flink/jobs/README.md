# Flink Jobs Directory

This directory is used to store your compiled Flink jobs (.jar files).

## How to Use

1. **Place your JAR files here**: After compiling your Flink project, copy the JAR to this folder.

2. **Submit a job**:
   ```bash
   docker exec -it flink-jobmanager flink run /opt/flink/jobs/your-job.jar
   ```

3. **Submit with arguments**:
   ```bash
   docker exec -it flink-jobmanager flink run \
     /opt/flink/jobs/your-job.jar \
     --input /path/to/input \
     --output /path/to/output
   ```

## Useful Links

- [Flink Project Template](https://github.com/apache/flink-quickstart)
