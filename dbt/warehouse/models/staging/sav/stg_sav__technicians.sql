{{ config(tags=['staging', 'sav']) }}

with base as (

    select * from {{ ref('base_sav__technicians') }}

)

select
    cast(id                               as varchar)   as id_technician,
    cast(coalesce(code, '')               as varchar)   as code,
    cast(coalesce(first_name, '')         as varchar)   as first_name,
    cast(coalesce(last_name, '')          as varchar)   as last_name,
    cast(coalesce(email, '')              as varchar)   as email,
    cast(''                               as varchar)   as phone,
    cast(coalesce(specialization, '')     as varchar)   as specialization,
    cast(coalesce(is_active, false)       as boolean)   as is_active,
    cast(created_at                       as timestamp) as created_at,
    cast(null as Nullable(DateTime64(3))) as updated_at,
    cast(latest_extracted_at                as timestamp) as _etl_loaded_at
from base
