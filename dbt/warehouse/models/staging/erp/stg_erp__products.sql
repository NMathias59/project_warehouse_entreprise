{{ config(tags=['staging', 'erp']) }}

with source as (
    select * from {{ source('erp', 'products') }}
)

select
    cast(id as varchar)                as id_product,
    cast(sku as varchar)               as sku,
    cast(name as varchar)              as name,
    cast(slug as varchar)              as slug,
    cast(specs as varchar)             as specs,
    cast(brand_id as varchar)          as brand_id,
    cast(is_active as boolean)         as is_active,
    cast(coalesce(weight_kg, 0) as decimal(38,9)) as weight_kg,
    cast(created_at as timestamp)      as created_at,
    cast(deleted_at as timestamp)      as deleted_at,
    cast(updated_at as timestamp)      as updated_at,
    cast(category_id as varchar)       as category_id,
    cast(description as varchar)       as description
from source
where id is not null
