{{ config(materialized='view', tags=['staging', 'sav']) }}

select
    id,
    argMax(technician_id,  _airbyte_extracted_at) as technician_id,
    argMax(status,         _airbyte_extracted_at) as status,
    argMax(diagnosis,      _airbyte_extracted_at) as diagnostic,
    argMax(repair_actions, _airbyte_extracted_at) as resolution,
    argMax(started_at,     _airbyte_extracted_at) as started_at,
    argMax(completed_at,   _airbyte_extracted_at) as completed_at,
    argMax(labor_minutes,  _airbyte_extracted_at) as duration_minutes,
    max(_airbyte_extracted_at)                    as latest_extracted_at
from {{ source('sav', 'interventions') }}
where id is not null
group by id
