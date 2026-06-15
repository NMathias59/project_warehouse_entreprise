{{ config(tags=['staging', 'mes']) }}

with base as (

    select * from {{ ref('base_mes__machine_downtime') }}

)

select
    cast(id                                   as varchar)       as id_machine_downtime,
    cast(coalesce(work_center_id, '')         as varchar)       as work_center_id,
    cast(''                                   as varchar)       as shift_id,
    cast(coalesce(downtime_type, '')          as varchar)       as downtime_type,
    cast(coalesce(reason_code, '')            as varchar)       as reason_code,
    cast(''                                   as varchar)       as description,
    cast(started_at                           as timestamp)     as started_at,
    toDateTimeOrNull(toString(ended_at))                        as ended_at,
    cast(coalesce(duration_minutes, 0)        as decimal(18,2)) as duration_minutes,
    cast(coalesce(reported_by, '')            as varchar)       as reported_by,
    cast(created_at                           as timestamp)     as created_at,
    cast(latest_extracted_at                as timestamp)     as _etl_loaded_at
from base
