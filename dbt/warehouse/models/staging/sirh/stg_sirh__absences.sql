{{ config(tags=['staging', 'sirh']) }}

with source as (

    select * from {{ source('sirh', 'absences') }}
    where id is not null

),

deduped as (

    select
        id,
        argMax(employee_id,       _airbyte_extracted_at) as employee_id,
        argMax(absence_type_id,   _airbyte_extracted_at) as absence_type_id,
        argMax(status,            _airbyte_extracted_at) as status,
        argMax(start_date,        _airbyte_extracted_at) as start_date,
        argMax(end_date,          _airbyte_extracted_at) as end_date,
        argMax(duration_days,     _airbyte_extracted_at) as duration_days,
        argMax(reason,            _airbyte_extracted_at) as reason,
        argMax(approved_by,       _airbyte_extracted_at) as approved_by,
        argMax(approved_at,       _airbyte_extracted_at) as approved_at,
        argMax(created_at,        _airbyte_extracted_at) as created_at,
        argMax(updated_at,        _airbyte_extracted_at) as updated_at,
        max(_airbyte_extracted_at)                       as latest_extracted_at
    from source
    group by id

)

select
    cast(id                                   as varchar)       as id_absence,
    cast(coalesce(employee_id, '')            as varchar)       as employee_id,
    cast(coalesce(absence_type_id, '')        as varchar)       as absence_type_id,
    cast(coalesce(status, '')                 as varchar)       as status,
    cast(start_date                           as date)          as start_date,
    cast(end_date                             as date)          as end_date,
    cast(coalesce(duration_days, 0)           as decimal(18,2)) as duration_days,
    cast(coalesce(reason, '')                 as varchar)       as reason,
    cast(coalesce(approved_by, '')            as varchar)       as approved_by,
    toDateTimeOrNull(toString(approved_at))                     as approved_at,
    cast(created_at                           as timestamp)     as created_at,
    toDateTimeOrNull(toString(updated_at))                      as updated_at,
    cast(latest_extracted_at                  as timestamp)     as _etl_loaded_at
from deduped
