{{ config(tags=['staging', 'qms']) }}

with source as (

    select * from {{ source('qms', 'audit_findings') }}
    where id is not null

),

deduped as (

    select
        id,
        argMax(audit_id,           _airbyte_extracted_at) as audit_id,
        argMax(finding_type,       _airbyte_extracted_at) as finding_type,
        argMax(description,        _airbyte_extracted_at) as description,
        argMax(standard_reference, _airbyte_extracted_at) as requirement_reference,
        argMax(nc_id,              _airbyte_extracted_at) as corrective_action_id,
        argMax(created_at,         _airbyte_extracted_at) as created_at,
        max(_airbyte_extracted_at)                        as latest_extracted_at
    from source
    group by id

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
    cast(latest_extracted_at                     as timestamp) as _etl_loaded_at
from deduped
