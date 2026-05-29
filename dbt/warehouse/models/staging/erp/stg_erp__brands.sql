{{ config(tags=['staging', 'erp']) }}

select
    cast(id as varchar)         as id_brand,
    cast(name as varchar)       as name,
    cast(slug as varchar)       as slug,
    cast(country as varchar)    as country,
    cast(created_at as timestamp)  as created_at,
    cast(deleted_at as timestamp)  as deleted_at,
    cast(updated_at as timestamp)  as updated_at,
    cast(logo_url as varchar)        as logo_url
from {{ source('erp', 'brands') }}
where id is not null
