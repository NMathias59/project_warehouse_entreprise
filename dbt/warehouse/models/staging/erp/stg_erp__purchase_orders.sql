{{ config(tags=['staging', 'erp']) }}

with source as (
    select * from {{ source('erp', 'purchase_orders') }}
)

select
    cast(id as varchar)                as id_purchase_order,
    cast(status as varchar)            as status,
    cast(currency as varchar)          as currency,
    cast(total_ht as decimal(38,9))    as total_ht,
    cast(reference as varchar)         as reference,
    cast(created_at as timestamp)      as created_at,
    cast(deleted_at as timestamp)      as deleted_at,
    cast(ordered_at as timestamp)      as ordered_at,
    cast(updated_at as timestamp)      as updated_at,
    cast(expected_at as date)          as expected_at,
    cast(supplier_id as varchar)       as supplier_id
from source
where id is not null
