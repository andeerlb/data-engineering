# Redshift
Amazon Redshift is a fully managed, petabyte-scale data warehouse service in the cloud. Amazon Redshift Serverless lets you access and analyze data without all of the configurations of a provisioned data warehouse.   

Resources are automatically provisioned and data warehouse capacity is intelligently scaled to deliver fast performance for even the most demanding and unpredictable workloads.

### Data ingestion
You can use the COPY command to ingest large volumes of data into Amazon Redshift.   

The COPY command loads data into a Redshift database table from data files or from an Amazon DynamoDB table. The files can be located in an Amazon S3 bucket, an Amazon EMR cluster, or a remote host that is accessed using a Secure Shell (SSH) connection.   

Depending on your use case, you can also use AWS services and features to perform data loads.   

### MPP (Massively Parallel Processing)
Amazon Redshift distributes the rows of a table to the compute so that data can be processed in parallel. With MPP, you can quickly run queries that operate on large amounts of data. The compute will handle all query processing. By selecting an appropriate distribution key for each table, you can optimize the distribution of data to balance the workload and minimize movement of data.   

Redshift also offers automatic table optimization (ATO). ATO is a self-tuning capability that automatically optimizes the design of tables by applying sort and distribution keys without the need for administrator intervention. By using automation to tune the design of tables, you can get started and get the fastest performance without investing time to manually tune and implement table optimizations.   

### Columnar storage
https://seattledataguy.substack.com/p/back-to-the-basics-what-is-columnar.  

Amazon Redshift uses columnar storage, which is optimal for analytical processing, where each data block stores values of a single column for multiple rows. Amazon Redshift transparently converts data to columnar storage for each column.   

Columnar storage optimizes analytic query performance by significantly reducing overall disk I/O requirements and the amount of data required to load into memory from disk. Additionally, when data is stored in columnar fashion, compression algorithms work more efficiently. This further reduces disk space and I/O, because each block holds the homogeneous type of data.

### Materialized views
You can use Amazon Redshift materialized views to achieve faster performance on your dashboard queries. Amazon Redshift materialized views retrieve the precomputed result set of the underlying data without accessing the base tables every time. They can also perform an automatic, incremental refresh when the base tables change. This inherently results in faster query output times.   

Use the following syntax to create a materialized view.   

```sql
CREATE MATERIALIZED VIEW mv_name
[ BACKUP { YES | NO } ]
[ table_attributes ]
[ AUTO REFRESH { YES | NO } ]
AS query
```

Now, break down the parameters in the command:

- The BACKUP clause specifies whether the materialized view is included in automated and manual cluster snapshots, which are stored in Amazon S3. The default value for BACKUP is YES. You can specify BACKUP NO to save processing time when you create and restore snapshots and to reduce the amount of storage required in Amazon S3.
- The table_attributes clause specifies how the data in the materialized view is distributed. For more information on the different styles of distribution, in the CREATE MATERIALIZED VIEW section of the Amazon Redshift Developers Guide, see Parameters(opens in a new tab). 
- The AUTO REFRESH clause defines whether the materialized view should be automatically refreshed with the latest changes from its base tables. The default value is NO.