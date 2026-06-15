{{ config(tags=['staging', 'qms']) }}

with base as (

    select * from {{ ref('base_qms__audit_findings') }}

)

select
    cast(id                                      as varchar)   as id_audit_finding,
    cast(coalesce(audit_id, '')                  as varchar)   as audit_id,
    cast(coalesce(finding_type, '')              as varchar)   as finding_type,
    cast(coalesce(description, '')               as varchar)   as description,
    cast(coalesce(requirement_reference, '')     as varchar)   as requirement_reference,
    cast(false                                   as boolean)   as is_critical,
    cast(coalesce(corrective_action_id, '')      as varchar)   as corrective_action_id,
    cast(created_at                              as timestamp) as created_at,
    cast(latest_extracted_at                as timestamp) as _etl_loaded_at
from base
