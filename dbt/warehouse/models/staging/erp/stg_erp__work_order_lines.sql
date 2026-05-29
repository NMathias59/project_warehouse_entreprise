{{ config(tags=['staging', 'erp']) }}

with source as (
    select * from {{ source('erp', 'work_order_lines') }}
)

select
    cast(id as varchar)                as id_work_order_line,
    cast(work_order_id as varchar)     as work_order_id,
    cast(component_id as varchar)      as component_id,
    cast(qty_planned as int)           as qty_planned,
    cast(qty_consumed as int)          as qty_consumed,
    cast(created_at as timestamp)      as created_at,
    cast(_ab_cdc_updated_at as varchar) as updated_at
from source
where id is not null
