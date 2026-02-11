# Creating the schemas
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