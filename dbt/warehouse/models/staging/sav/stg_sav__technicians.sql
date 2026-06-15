{{ config(tags=['staging', 'sav']) }}

with source as (

    select * from {{ source('sav', 'technicians') }}
    where id is not null

),

deduped as (

    select
        id,
        argMax(badge_number, _airbyte_extracted_at) as code,
        argMax(first_name,   _airbyte_extracted_at) as first_name,
        argMax(last_name,    _airbyte_extracted_at) as last_name,
        argMax(email,        _airbyte_extracted_at) as email,
        argMax(team,         _airbyte_extracted_at) as specialization,
        argMax(is_active,    _airbyte_extracted_at) as is_active,
        argMax(created_at,   _airbyte_extracted_at) as created_at,
        max(_airbyte_extracted_at)                  as latest_extracted_at
    from source
    group by id

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
    cast(latest_extracted_at              as timestamp) as _etl_loaded_at
from deduped
