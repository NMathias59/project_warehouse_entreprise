{{ config(tags=['staging', 'qms']) }}

with source as (

    select * from {{ source('qms', 'certifications') }}
    where id is not null

),

deduped as (

    select
        id,
        argMax(status,             _airbyte_extracted_at) as status,
        argMax(qualification_date, _airbyte_extracted_at) as valid_from,
        argMax(next_audit_date,    _airbyte_extracted_at) as valid_until,
        argMax(last_audit_date,    _airbyte_extracted_at) as last_audit_at,
        argMax(created_at,         _airbyte_extracted_at) as created_at,
        argMax(updated_at,         _airbyte_extracted_at) as updated_at,
        max(_airbyte_extracted_at)                        as latest_extracted_at
    from source
    group by id

)

select
    cast(id                                    as varchar)   as id_certification,
    cast(''                                    as varchar)   as certification_type,
    cast(''                                    as varchar)   as certification_body,
    cast(''                                    as varchar)   as certificate_number,
    cast(''                                    as varchar)   as scope,
    cast(coalesce(status, '')                  as varchar)   as status,
    cast(valid_from                            as date)      as valid_from,
    cast(valid_until                           as date)      as valid_until,
    toDateTimeOrNull(toString(last_audit_at))                as last_audit_at,
    cast(created_at                            as timestamp) as created_at,
    toDateTimeOrNull(toString(updated_at))                   as updated_at,
    cast(latest_extracted_at                   as timestamp) as _etl_loaded_at
from deduped
