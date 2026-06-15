{{ config(tags=['staging', 'qms']) }}

with base as (

    select * from {{ ref('base_qms__audits') }}

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
    cast(latest_extracted_at                as timestamp) as _etl_loaded_at
from base
