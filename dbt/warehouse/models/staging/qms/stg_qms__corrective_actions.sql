{{ config(tags=['staging', 'qms']) }}

with base as (

    select * from {{ ref('base_qms__corrective_actions') }}

)

select
    cast(id                                   as varchar)   as id_corrective_action,
    cast(coalesce(non_conformity_id, '')      as varchar)   as non_conformity_id,
    cast(''                                   as varchar)   as reference,
    cast(coalesce(action_type, '')            as varchar)   as action_type,
    cast(coalesce(description, '')            as varchar)   as description,
    cast(coalesce(responsible_id, '')         as varchar)   as responsible_id,
    cast(coalesce(status, '')                 as varchar)   as status,
    cast(''                                   as varchar)   as root_cause,
    toDateTimeOrNull(toString(due_at))                      as due_at,
    toDateTimeOrNull(toString(implemented_at))              as implemented_at,
    cast(null as Nullable(DateTime64(3)))                   as verified_at,
    cast(''                                   as varchar)   as verified_by,
    cast(created_at                           as timestamp) as created_at,
    cast(null as Nullable(DateTime64(3)))                   as updated_at,
    cast(latest_extracted_at                as timestamp) as _etl_loaded_at
from base
