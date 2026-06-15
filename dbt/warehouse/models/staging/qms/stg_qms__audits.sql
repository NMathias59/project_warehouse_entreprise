{{ config(tags=['staging', 'qms']) }}

with source as (

    select * from {{ source('qms', 'audits') }}
    where id is not null

),

deduped as (

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
        max(_airbyte_extracted_at)                   as latest_extracted_at
    from source
    group by id

)

select
    cast(id                                   as varchar)   as id_audit,
    cast(coalesce(reference, '')              as varchar)   as reference,
    cast(coalesce(audit_type, '')             as varchar)   as audit_type,
    cast(coalesce(scope, '')                  as varchar)   as scope,
    cast(coalesce(auditor_id, '')             as varchar)   as auditor_id,
    cast(''                                   as varchar)   as auditee_department,
    toDateTimeOrNull(toString(planned_at))                  as planned_at,
    toDateTimeOrNull(toString(started_at))                  as started_at,
    cast(null as Nullable(DateTime64(3)))                   as completed_at,
    cast(coalesce(overall_result, '')         as varchar)   as status,
    cast(coalesce(overall_result, '')         as varchar)   as overall_result,
    cast(created_at                           as timestamp) as created_at,
    cast(null as Nullable(DateTime64(3)))                   as updated_at,
    cast(latest_extracted_at                  as timestamp) as _etl_loaded_at
from deduped
