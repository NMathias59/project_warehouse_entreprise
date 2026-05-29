{{ config(tags=['staging', 'erp']) }}

with source as (
    select * from {{ source('erp', 'pc_models') }}
)

select
    cast(id as varchar)                as id_pc_model,
    cast(code as varchar)              as code,
    cast(name as varchar)              as name,
    cast(is_active as boolean)         as is_active,
    cast(created_at as timestamp)      as created_at,
    cast(deleted_at as timestamp)      as deleted_at,
    cast(coalesce(product_id, '') as varchar)        as product_id,
    cast(coalesce(description, '') as varchar)      as description
from source
where id is not null
