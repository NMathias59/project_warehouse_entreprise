{{ config(tags=['staging', 'sav']) }}

with source as (

    select * from {{ source('sav', 'spare_parts_used') }}
    where id is not null

),

deduped as (

    select
        id,
        argMax(intervention_id,    _airbyte_extracted_at) as intervention_id,
        argMax(part_reference,     _airbyte_extracted_at) as part_reference,
        argMax(part_name,          _airbyte_extracted_at) as part_name,
        argMax(quantity,           _airbyte_extracted_at) as quantity,
        argMax(unit_cost,          _airbyte_extracted_at) as unit_cost,
        argMax(is_under_warranty,  _airbyte_extracted_at) as is_under_warranty,
        argMax(created_at,         _airbyte_extracted_at) as created_at,
        max(_airbyte_extracted_at)                        as latest_extracted_at
    from source
    group by id

)

select
    cast(id                                     as varchar)       as id_spare_part_used,
    cast(coalesce(intervention_id, '')          as varchar)       as intervention_id,
    cast(coalesce(part_reference, '')           as varchar)       as part_reference,
    cast(coalesce(part_name, '')                as varchar)       as part_name,
    cast(coalesce(quantity, 0)                  as decimal(18,2)) as quantity,
    cast(coalesce(unit_cost, 0)                 as decimal(18,2)) as unit_cost,
    cast(coalesce(is_under_warranty, false)     as boolean)       as is_under_warranty,
    cast(created_at                             as timestamp)     as created_at,
    cast(latest_extracted_at                    as timestamp)     as _etl_loaded_at
from deduped
