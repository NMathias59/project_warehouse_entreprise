{{ config(tags=['staging', 'qms']) }}

with source as (

    select * from {{ source('qms', 'audits') }}
    where id is not null

),

deduped as (

    select
        id,
        argMax(reference,            _airbyte_extracted_at) as reference,
        argMax(audit_type,           _airbyte_extracted_at) as audit_type,
        argMax(scope,                _airbyte_extracted_at) as scope,
        argMax(auditor_id,           _airbyte_extracted_at) as auditor_id,
        argMax(auditee_department,   _airbyte_extracted_at) as auditee_department,
        argMax(planned_at,           _airbyte_extracted_at) as planned_at,
        argMax(started_at,           _airbyte_extracted_at) as started_at,
        argMax(completed_at,         _airbyte_extracted_at) as completed_at,
        argMax(status,               _airbyte_extracted_at) as status,
        argMax(overall_result,       _airbyte_extracted_at) as overall_result,
        argMax(created_at,           _airbyte_extracted_at) as created_at,
        argMax(updated_at,           _airbyte_extracted_at) as updated_at,
        max(_airbyte_extracted_at)                          as latest_extracted_at
    from source
    group by id

)

select
    cast(id                                   as varchar)   as id_audit,
    cast(coalesce(reference, '')              as varchar)   as reference,
    cast(coalesce(audit_type, '')             as varchar)   as audit_type,
    cast(coalesce(scope, '')                  as varchar)   as scope,
    cast(coalesce(auditor_id, '')             as varchar)   as auditor_id,
    cast(coalesce(auditee_department, '')     as varchar)   as auditee_department,
    toDateTimeOrNull(toString(planned_at))                  as planned_at,
    toDateTimeOrNull(toString(started_at))                  as started_at,
    toDateTimeOrNull(toString(completed_at))                as completed_at,
    cast(coalesce(status, '')                 as varchar)   as status,
    cast(coalesce(overall_result, '')         as varchar)   as overall_result,
    cast(created_at                           as timestamp) as created_at,
    toDateTimeOrNull(toString(updated_at))                  as updated_at,
    cast(latest_extracted_at                  as timestamp) as _etl_loaded_at
from deduped
