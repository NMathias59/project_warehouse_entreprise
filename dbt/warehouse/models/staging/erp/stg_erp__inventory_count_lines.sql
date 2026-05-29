{{ config(tags=['staging', 'erp']) }}

with source as (
    select * from {{ source('erp', 'inventory_count_lines') }}
)

select
    cast(id as varchar)                    as id_inventory_count_line,
    cast(inventory_count_id as varchar)    as inventory_count_id,
    cast(component_id as varchar)          as component_id,
    -- protect against NULLs: ClickHouse errors when casting NULL to non-nullable types
    cast(coalesce(counted_qty, 0) as int)  as counted_qty,
    cast(coalesce(expected_qty, 0) as int) as expected_qty,
    cast(coalesce(variance, 0) as int)     as variance,
    cast(counted_at as timestamp)          as counted_at,
    cast(coalesce(location_id, '') as varchar)           as location_id
from source
where id is not null
