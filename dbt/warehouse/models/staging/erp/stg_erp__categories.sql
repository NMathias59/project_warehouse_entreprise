{{ config(tags=['staging', 'erp']) }}

select cast(id as varchar)           as id_category,
       cast(name as varchar)         as name,
       cast(slug as varchar)         as slug,
       cast(parent_id as varchar)    as parent_id,
       cast(created_at as timestamp) as created_at,
       cast(deleted_at as timestamp) as deleted_at,
       cast(updated_at as timestamp) as updated_at,
       cast(description as varchar)  as description
from {{ source('erp', 'categories') }}
where id is not null
