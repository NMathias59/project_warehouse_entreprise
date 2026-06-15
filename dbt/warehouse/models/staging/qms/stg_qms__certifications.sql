{{ config(tags=['staging', 'qms']) }}

with base as (

    select * from {{ ref('base_qms__certifications') }}

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
    cast(latest_extracted_at                as timestamp) as _etl_loaded_at
from base
