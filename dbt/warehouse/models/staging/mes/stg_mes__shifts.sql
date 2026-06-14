{{ config(tags=['staging', 'mes']) }}

with source as (

    select * from {{ source('mes', 'shifts') }}
    where id is not null

),

deduped as (

    select
        id,
        argMax(name,           _airbyte_extracted_at) as name,
        argMax(start_time,     _airbyte_extracted_at) as start_time,
        argMax(end_time,       _airbyte_extracted_at) as end_time,
        argMax(is_night_shift, _airbyte_extracted_at) as is_night_shift,
        argMax(is_active,      _airbyte_extracted_at) as is_active,
        argMax(created_at,     _airbyte_extracted_at) as created_at,
        max(_airbyte_extracted_at)                    as latest_extracted_at
    from source
    group by id

)

select
    cast(id                                as varchar)   as id_shift,
    cast(coalesce(name, '')               as varchar)   as name,
    cast(coalesce(start_time, '')         as varchar)   as start_time,
    cast(coalesce(end_time, '')           as varchar)   as end_time,
    cast(coalesce(is_night_shift, false)  as boolean)   as is_night_shift,
    cast(coalesce(is_active, false)       as boolean)   as is_active,
    cast(created_at                       as timestamp) as created_at,
    cast(latest_extracted_at              as timestamp) as _etl_loaded_at
from deduped
