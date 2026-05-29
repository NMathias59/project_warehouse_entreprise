{{ config(tags=['staging', 'erp']) }}

with source as (
    select * from {{ source('erp', 'warehouses') }}
)

select
    cast(id as varchar)              as id_warehouse,
    cast(code as varchar)            as code,
    cast(name as varchar)            as name,
    cast(address as varchar)         as address,
    cast(is_active as boolean)       as is_active,
    cast(created_at as timestamp)    as created_at,
    cast(updated_at as timestamp)    as updated_at
from source
where id is not null
