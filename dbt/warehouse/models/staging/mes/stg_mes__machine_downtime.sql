{{ config(tags=['staging', 'mes']) }}

with source as (

    select * from {{ source('mes', 'machine_downtime') }}
    where id is not null

),

deduped as (

    select
        id,
        argMax(work_center_id,    _airbyte_extracted_at) as work_center_id,
        argMax(shift_id,          _airbyte_extracted_at) as shift_id,
        argMax(downtime_type,     _airbyte_extracted_at) as downtime_type,
        argMax(reason_code,       _airbyte_extracted_at) as reason_code,
        argMax(description,       _airbyte_extracted_at) as description,
        argMax(started_at,        _airbyte_extracted_at) as started_at,
        argMax(ended_at,          _airbyte_extracted_at) as ended_at,
        argMax(duration_minutes,  _airbyte_extracted_at) as duration_minutes,
        argMax(reported_by,       _airbyte_extracted_at) as reported_by,
        argMax(created_at,        _airbyte_extracted_at) as created_at,
        max(_airbyte_extracted_at)                       as latest_extracted_at
    from source
    group by id

)

select
    cast(id                                   as varchar)       as id_machine_downtime,
    cast(coalesce(work_center_id, '')         as varchar)       as work_center_id,
    cast(coalesce(shift_id, '')               as varchar)       as shift_id,
    cast(coalesce(downtime_type, '')          as varchar)       as downtime_type,
    cast(coalesce(reason_code, '')            as varchar)       as reason_code,
    cast(coalesce(description, '')            as varchar)       as description,
    cast(started_at                           as timestamp)     as started_at,
    toDateTimeOrNull(toString(ended_at))                        as ended_at,
    cast(coalesce(duration_minutes, 0)        as decimal(18,2)) as duration_minutes,
    cast(coalesce(reported_by, '')            as varchar)       as reported_by,
    cast(created_at                           as timestamp)     as created_at,
    cast(latest_extracted_at                  as timestamp)     as _etl_loaded_at
from deduped
