{{ config(tags=['staging', 'erp']) }}

with source as (
    select * from {{ source('erp', 'inventory_counts') }}
)

select
    cast(id as varchar)                as id_inventory_count,
    cast(status as varchar)            as status,
    cast(reference as varchar)         as reference,
    cast(counted_by as varchar)        as counted_by,
    cast(started_at as timestamp)      as started_at,
    cast(completed_at as timestamp)    as completed_at,
    cast(validated_at as timestamp)    as validated_at,
    cast(warehouse_id as varchar)      as warehouse_id,
    cast(created_at as timestamp)      as created_at
from source
where id is not null
