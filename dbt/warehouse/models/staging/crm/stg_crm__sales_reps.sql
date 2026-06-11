{{ config(tags=['staging', 'crm']) }}

select
    cast(id                        as varchar)   as id_sales_rep,
    cast(coalesce(code, '')        as varchar)   as code,
    cast(coalesce(first_name, '')  as varchar)   as first_name,
    cast(coalesce(last_name, '')   as varchar)   as last_name,
    cast(coalesce(email, '')       as varchar)   as email,
    cast(coalesce(territory, '')   as varchar)   as territory,
    cast(is_active                 as boolean)   as is_active,
    cast(created_at                as timestamp) as created_at,
    cast(_airbyte_extracted_at     as timestamp) as _etl_loaded_at
from {{ source('crm', 'sales_reps') }}
where id is not null
