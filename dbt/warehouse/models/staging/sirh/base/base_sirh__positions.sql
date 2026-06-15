{{ config(materialized='view', tags=['staging', 'sirh']) }}

select
    id,
    argMax(title,         _airbyte_extracted_at) as title,
    argMax(department_id, _airbyte_extracted_at) as department_id,
    argMax(level,         _airbyte_extracted_at) as seniority_level,
    argMax(is_active,     _airbyte_extracted_at) as is_active,
    argMax(created_at,    _airbyte_extracted_at) as created_at,
    max(_airbyte_extracted_at)                    as latest_extracted_at
from {{ source('sirh', 'positions') }}
where id is not null
group by id
