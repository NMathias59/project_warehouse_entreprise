{{ config(materialized='view', tags=['staging', 'qms']) }}

select
    id,
    argMax(status,             _airbyte_extracted_at) as status,
    argMax(qualification_date, _airbyte_extracted_at) as valid_from,
    argMax(next_audit_date,    _airbyte_extracted_at) as valid_until,
    argMax(last_audit_date,    _airbyte_extracted_at) as last_audit_at,
    argMax(created_at,         _airbyte_extracted_at) as created_at,
    argMax(updated_at,         _airbyte_extracted_at) as updated_at,
    max(_airbyte_extracted_at)                    as latest_extracted_at
from {{ source('qms', 'certifications') }}
where id is not null
group by id
