{{ config(tags=['staging', 'erp']) }}

with source as (
    select * from {{ source('erp', 'purchase_order_lines') }}
)

select
    cast(id as varchar)                as id_purchase_order_line,
    cast(quantity as int)              as quantity,
    cast(total_ht as decimal(38,9))    as total_ht,
    cast(unit_price as decimal(38,9))  as unit_price,
    cast(created_at as timestamp)      as created_at,
    cast(component_id as varchar)      as component_id,
    cast(purchase_order_id as varchar) as purchase_order_id
from source
where id is not null
