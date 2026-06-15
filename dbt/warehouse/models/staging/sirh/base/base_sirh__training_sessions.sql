{{ config(materialized='view', tags=['staging', 'sirh']) }}

select
    id,
    argMax(title,          _airbyte_extracted_at) as title,
    argMax(course_type,    _airbyte_extracted_at) as training_type,
    argMax(provider,       _airbyte_extracted_at) as provider,
    argMax(duration_hours, _airbyte_extracted_at) as duration_hours,
    argMax(cost_eur,       _airbyte_extracted_at) as cost_per_person,
    argMax(is_mandatory,   _airbyte_extracted_at) as is_mandatory,
    argMax(created_at,     _airbyte_extracted_at) as created_at,
    max(_airbyte_extracted_at)                    as latest_extracted_at
from {{ source('sirh', 'training_sessions') }}
where id is not null
group by id
