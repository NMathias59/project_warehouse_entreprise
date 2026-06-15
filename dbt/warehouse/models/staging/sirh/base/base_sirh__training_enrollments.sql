{{ config(materialized='view', tags=['staging', 'sirh']) }}

select
    id,
    argMax(course_id,       _airbyte_extracted_at) as training_session_id,
    argMax(employee_id,     _airbyte_extracted_at) as employee_id,
    argMax(status,          _airbyte_extracted_at) as status,
    argMax(score,           _airbyte_extracted_at) as score,
    argMax(certificate_ref, _airbyte_extracted_at) as certificate_ref,
    argMax(end_date,        _airbyte_extracted_at) as completed_at,
    argMax(created_at,      _airbyte_extracted_at) as created_at,
    max(_airbyte_extracted_at)                    as latest_extracted_at
from {{ source('sirh', 'training_enrollments') }}
where id is not null
group by id
