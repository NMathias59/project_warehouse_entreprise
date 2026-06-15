{{ config(tags=['staging', 'sirh']) }}

with base as (

    select * from {{ ref('base_sirh__training_enrollments') }}

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
    cast(latest_extracted_at                as timestamp)     as _etl_loaded_at
from base
