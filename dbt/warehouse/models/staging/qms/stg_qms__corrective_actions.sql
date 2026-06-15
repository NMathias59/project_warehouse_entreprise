{{ config(tags=['staging', 'qms']) }}

with source as (

    select * from {{ source('qms', 'corrective_actions') }}
    where id is not null

),

deduped as (

    select
        id,
        argMax(nc_id,           _airbyte_extracted_at) as non_conformity_id,
        argMax(action_type,     _airbyte_extracted_at) as action_type,
        argMax(description,     _airbyte_extracted_at) as description,
        argMax(owner_ref,       _airbyte_extracted_at) as responsible_id,
        argMax(status,          _airbyte_extracted_at) as status,
        argMax(due_date,        _airbyte_extracted_at) as due_at,
        argMax(completed_date,  _airbyte_extracted_at) as implemented_at,
        argMax(created_at,      _airbyte_extracted_at) as created_at,
        max(_airbyte_extracted_at)                     as latest_extracted_at
    from source
    group by id

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
    cast(latest_extracted_at                  as timestamp) as _etl_loaded_at
from deduped
