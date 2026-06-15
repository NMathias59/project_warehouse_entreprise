{{ config(materialized='view', tags=['staging', 'sirh']) }}

select
    id,
    argMax(employee_id,    _airbyte_extracted_at) as employee_id,
    argMax(leave_type,     _airbyte_extracted_at) as absence_type_id,
    argMax(status,         _airbyte_extracted_at) as status,
    argMax(start_date,     _airbyte_extracted_at) as start_date,
    argMax(end_date,       _airbyte_extracted_at) as end_date,
    argMax(days,           _airbyte_extracted_at) as duration_days,
    argMax(reason,         _airbyte_extracted_at) as reason,
    argMax(approved_by_id, _airbyte_extracted_at) as approved_by,
    argMax(decided_at,     _airbyte_extracted_at) as approved_at,
    argMax(submitted_at,   _airbyte_extracted_at) as created_at,
    max(_airbyte_extracted_at)                    as latest_extracted_at
from {{ source('sirh', 'absences') }}
where id is not null
group by id
