{{ config(tags=['staging', 'erp']) }}

with source as (
    select * from {{ source('erp', 'departments') }}
)

select
    cast(id as varchar)              as id_department,
    cast(code as varchar)            as code,
    cast(name as varchar)            as name,
    cast(created_at as timestamp)    as created_at,
    cast(_ab_cdc_updated_at as varchar) as updated_at
from source
where id is not null
