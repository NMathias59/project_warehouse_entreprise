{{ config(materialized='view', tags=['staging', 'qms']) }}

select
    id,
    argMax(audit_number,  _airbyte_extracted_at) as reference,
    argMax(audit_type,    _airbyte_extracted_at) as audit_type,
    argMax(scope,         _airbyte_extracted_at) as scope,
    argMax(auditor_ref,   _airbyte_extracted_at) as auditor_id,
    argMax(planned_date,  _airbyte_extracted_at) as planned_at,
    argMax(actual_date,   _airbyte_extracted_at) as started_at,
    argMax(status,        _airbyte_extracted_at) as overall_result,
    argMax(created_at,    _airbyte_extracted_at) as created_at,
    max(_airbyte_extracted_at)                    as latest_extracted_at
from {{ source('qms', 'audits') }}
where id is not null
group by id
