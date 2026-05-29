{{ config(tags=['staging', 'erp']) }}

with source as (
    select * from {{ source('erp', 'product_compatibility') }}
)

select
    cast(id as varchar)                as id_product_compatibility,
    cast(note as varchar)              as note,
    cast(level as varchar)             as level,
    cast(specs_match as varchar)       as specs_match,
    cast(product_a_id as varchar)      as product_a_id,
    cast(product_b_id as varchar)      as product_b_id,
    cast(compatibility_type as varchar) as compatibility_type,
    cast(created_at as timestamp)      as created_at
from source
where id is not null
