{{ config(materialized='view', tags=['staging', 'sav']) }}

select
    id,
    argMax(badge_number, _airbyte_extracted_at) as code,
    argMax(first_name,   _airbyte_extracted_at) as first_name,
    argMax(last_name,    _airbyte_extracted_at) as last_name,
    argMax(email,        _airbyte_extracted_at) as email,
    argMax(team,         _airbyte_extracted_at) as specialization,
    argMax(is_active,    _airbyte_extracted_at) as is_active,
    argMax(created_at,   _airbyte_extracted_at) as created_at,
    max(_airbyte_extracted_at)                    as latest_extracted_at
from {{ source('sav', 'technicians') }}
where id is not null
group by id
