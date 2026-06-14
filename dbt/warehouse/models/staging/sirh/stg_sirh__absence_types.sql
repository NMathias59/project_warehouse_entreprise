{{ config(tags=['staging', 'sirh']) }}

with source as (

    select * from {{ source('sirh', 'absence_types') }}
    where id is not null

),

deduped as (

    select
        id,
        argMax(code,              _airbyte_extracted_at) as code,
        argMax(label,             _airbyte_extracted_at) as label,
        argMax(is_paid,           _airbyte_extracted_at) as is_paid,
        argMax(requires_approval, _airbyte_extracted_at) as requires_approval,
        argMax(is_active,         _airbyte_extracted_at) as is_active,
        argMax(created_at,        _airbyte_extracted_at) as created_at,
        max(_airbyte_extracted_at)                       as latest_extracted_at
    from source
    group by id

)

select
    cast(id                                   as varchar)   as id_absence_type,
    cast(coalesce(code, '')                   as varchar)   as code,
    cast(coalesce(label, '')                  as varchar)   as label,
    cast(coalesce(is_paid, false)             as boolean)   as is_paid,
    cast(coalesce(requires_approval, false)   as boolean)   as requires_approval,
    cast(coalesce(is_active, false)           as boolean)   as is_active,
    cast(created_at                           as timestamp) as created_at,
    cast(latest_extracted_at                  as timestamp) as _etl_loaded_at
from deduped
