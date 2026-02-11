# What is dbt? (Data Build Tool)

**dbt** (short for *Data Build Tool*) is an open-source tool that helps data teams **transform raw data into clean, tested, and documented datasets directly in a data warehouse** using simple SQL and software engineering best practices.


## Core Concept

dbt focuses exclusively on the **“T” in ELT** (Extract, Load, Transform):

1. **Extract & Load (EL)** – Your raw data is first loaded into a cloud data warehouse (e.g., Snowflake, BigQuery, Redshift).
2. **dbt Transform (T)** – dbt then **runs SQL-based transformations inside that warehouse**, turning raw tables into analytics-ready models.

Unlike traditional ETL tools, dbt does *not* extract data from source systems or load it into the warehouse — it assumes the data is already there.


## What dbt Does

### 1. Modular SQL Models

You write **SQL SELECT statements** to define transformation logic — each file represents a *model*. dbt figures out the dependency order and runs them correctly.

### 2. Software Engineering Best Practices

dbt brings practices like:

- **Version control** (Git)
- **Testing and data quality checks**
- **Documentation generation**
- **Modularity and reuse** into analytics workflows — making them reliable and maintainable.

### 3. Automated Documentation

dbt can generate beautiful docs that show tables, dependencies, and field descriptions — helping teams understand the data lineage and logic.

### 4. Data Testing and Validation

Define tests (e.g., `not null`, `unique`) to ensure data meets quality rules before it’s used downstream.

### 5. Works in Your Warehouse

dbt **executes compiled SQL directly inside your data warehouse**, leveraging its compute power instead of moving data around.


## Why Use dbt?

Here are the main benefits:

- **Reusability & Modularity** – Break complex transformations into small, reusable pieces.
- **Collaboration via Git** – Teams can safely work together with branching, reviews, and version history.
- **Automated Tests** – Quickly catch issues with automated data checks.
- **Clear Documentation & Lineage** – Easy to understand how and where data comes from.
- **Standardized Analytics Logic** – Everyone uses the same business logic definitions.

## How it Works (High-Level)

1. **Write models** as SQL SELECT queries.  
2. **dbt compiles** them into executable SQL.  
3. **dbt runs** these against your warehouse in the correct dependency order.  
4. **dbt builds** tables/views based on your configuration.  
5. **Run tests** and generate docs automatically.


## dbt Ecosystem

dbt has a rich ecosystem:

- **dbt Core** – open-source CLI tool.
- **dbt Cloud / Platform** – hosted service with UI, scheduling, observability, and collaboration features.
- **Packages & Community** – reusable code libraries and macros from the community.

---

### Creating the schemas
To create the schemas and tables that we will be placing your raw data into.

```
create schema if not exists jaffle_shop;
create schema if not exists stripe;

create table jaffle_shop.customers(
    id integer,
    first_name varchar(50),
    last_name varchar(50)
);

create table jaffle_shop.orders(
    id integer,
    user_id integer,
    order_date date,
    status varchar(50)
);

create table stripe.payment(
    id integer,
    orderid integer,
    paymentmethod varchar(50),
    status varchar(50),
    amount integer,
    created date
);
```

Ensure that you can run a select * from each of the tables with the following code snippets.
```
select * from jaffle_shop.customers;
select * from jaffle_shop.orders;
select * from stripe.payment;
```

### to copy the data from S3 into redshift

```
copy jaffle_shop.customers(id, first_name, last_name)
from 's3://<S3_BUCKET_NAME>/jaffle_shop_customers.csv'
iam_role 'arn:aws:iam::XXXXXXXXXX:role/RoleName'
region 'us-east-1'
delimiter ','
ignoreheader 1
acceptinvchars;
   
copy jaffle_shop.orders(id, user_id, order_date, status)
from 's3://<S3_BUCKET_NAME>/jaffle_shop_orders.csv'
iam_role 'arn:aws:iam::XXXXXXXXXX:role/RoleName'
region 'us-east-1'
delimiter ','
ignoreheader 1
acceptinvchars;

copy stripe.payment(id, orderid, paymentmethod, status, amount, created)
from 's3://<S3_BUCKET_NAME>/stripe_payments.csv'
iam_role 'arn:aws:iam::XXXXXXXXXX:role/RoleName'
region 'us-east-1'
delimiter ','
ignoreheader 1
Acceptinvchars;
```