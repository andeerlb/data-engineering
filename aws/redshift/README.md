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
- The table_attributes clause specifies how the data in the materialized view is distributed.
- The AUTO REFRESH clause defines whether the materialized view should be automatically refreshed with the latest changes from its base tables. The default value is NO.

### Zero ETL Integrations
Zero-ETL integration is a fully managed solution that makes transactional and operational data available in Amazon Redshift from multiple operational and transactional sources. With this solution, you can configure an integration from your source to an Amazon Redshift data warehouse. You don't need to maintain an extract, transform, and load (ETL) pipeline. We take care of the ETL for you by automating the creation and management of data replication from the data source to the Amazon Redshift cluster or Redshift Serverless namespace. You can continue to update and query your source data while simultaneously using Amazon Redshift for analytic workloads, such as reporting and dashboards.

With zero-ETL integration you have fresher data for analytics, AI/ML, and reporting. You get more accurate and timely insights for use cases like business dashboards, optimized gaming experience, data quality monitoring, and customer behavior analysis. You can make data-driven predictions with more confidence, improve customer experiences, and promote data-driven insights across the business.

The following sources are currently supported for zero-ETL integrations:

- Amazon Aurora MySQL (AMS)
- Amazon Aurora PostgreSQL (APG)
- Amazon DynamoDB
- Amazon RDS for MySQL
- Amazon RDS for Oracle
- Amazon RDS for PostgreSQL
- Oracle Database@AWS
- Applications including Salesforce, Salesforce Marketing Cloud Account Engagement, SAP, ServiceNow, Instagram ads, Meta ads, and Zendesk
Self-Managed MySQL, PostgreSQL, SQL Server, and Oracle

To create a zero-ETL integration, you specify an integration source and an Amazon Redshift data warehouse as the target. After an initial data load, the integration replicates data from the source to the target data warehouse. The data becomes available in Amazon Redshift. You control the encryption of your data when you create the integration source, when you create the zero-ETL integration, and when you create the Amazon Redshift data warehouse. The integration monitors the health of the data pipeline and recovers from issues when possible. You can create integrations from sources of the same type into a single Amazon Redshift data warehouse to derive holistic insights across multiple applications.

With the data in Amazon Redshift, you can use analytics that Amazon Redshift provides. For example, built-in machine learning (ML), materialized views, data sharing, and direct access to multiple data stores and data lakes. For data engineers, zero-ETL integration provides access to time-sensitive data that otherwise can get delayed by intermittent errors in complex data pipelines. You can run analytical queries and ML models on transactional data to derive timely insights for time-sensitive events and business decisions.

You can create an Amazon Redshift event notification subscription so you can be notified when an event occurs for a given zero-ETL integration. To view the list of integration-related event notifications, see Zero-ETL integration event notifications with Amazon EventBridge. The simplest way to create a subscription is with the Amazon SNS console.

#### Zero ETL Requirements

- Turn on case sensitivity for your data warehouse.
    - You can attach a parameter group and enable case sensitivity for a provisioned cluster during creation. However, you can update a serverless workgroup through the AWS Command Line Interface (AWS CLI) only after it's been created. This is required to support the case sensitivity of source tables and columns. The enable_case_sensitive_identifier is a configuration value that determines whether name identifiers of databases, tables, and columns are case sensitive. This parameter must be turned on to create zero-ETL integrations in the data warehouse.
- Add authorized principals
    - Authorized principal – identifies the user or role that can create zero-ETL integrations into the data warehouse.
    - Authorized integration source – identifies the source database that can update the data warehouse.

To create a zero-ETL integration into your Redshift Serverless workgroup or provisioned cluster, authorize access to the associated namespace or provisioned cluster.

You can skip this step if both of the following conditions are true:

- The AWS account that owns the Redshift Serverless workgroup or provisioned cluster also owns the source database.
- That principal is associated with an identity-based IAM policy with permissions to create zero-ETL integrations into this Redshift Serverless namespace or provisioned cluster.

- Docs to create Zero-ETL for each datasource (https://docs.aws.amazon.com/redshift/latest/mgmt/zero-etl-setting-up.create-integration.html)