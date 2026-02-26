{% snapshot customers_snapshot %}

{{
    config(
      target_schema='snapshots',
      unique_key='customer_id',
      strategy='check',
      check_cols=['status']
    )
}}

select
    id as customer_id,
    status,
    updated_at
from {{ source('jaffle_shop', 'customers') }}

{% endsnapshot %}
