{{ config(tags=['staging', 'sirh']) }}

with source as (

    select * from {{ source('sirh', 'training_enrollments') }}
    where id is not null

),

deduped as (

    select
        id,
        argMax(course_id,       _airbyte_extracted_at) as training_session_id,
        argMax(employee_id,     _airbyte_extracted_at) as employee_id,
        argMax(status,          _airbyte_extracted_at) as status,
        argMax(score,           _airbyte_extracted_at) as score,
        argMax(certificate_ref, _airbyte_extracted_at) as certificate_ref,
        argMax(end_date,        _airbyte_extracted_at) as completed_at,
        argMax(created_at,      _airbyte_extracted_at) as created_at,
        max(_airbyte_extracted_at)                     as latest_extracted_at
    from source
    group by id

)

select
    cast(id                                    as varchar)       as id_training_enrollment,
    cast(coalesce(training_session_id, '')     as varchar)       as training_session_id,
    cast(coalesce(employee_id, '')             as varchar)       as employee_id,
    cast(coalesce(status, '')                  as varchar)       as status,
    cast(coalesce(score, 0)                    as decimal(18,2)) as score,
    cast(certificate_ref is not null           as boolean)       as certificate_issued,
    cast(created_at                            as timestamp)     as enrolled_at,
    toDateTimeOrNull(toString(completed_at))                     as completed_at,
    cast(created_at                            as timestamp)     as created_at,
    cast(latest_extracted_at                   as timestamp)     as _etl_loaded_at
from deduped
