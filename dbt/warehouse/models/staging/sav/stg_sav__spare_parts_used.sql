{{ config(tags=['staging', 'sav']) }}

with base as (

    select * from {{ ref('base_sav__spare_parts_used') }}

)

select
    cast(id                                     as varchar)       as id_spare_part_used,
    cast(coalesce(intervention_id, '')          as varchar)       as intervention_id,
    cast(coalesce(part_reference, '')           as varchar)       as part_reference,
    cast(coalesce(part_name, '')                as varchar)       as part_name,
    cast(coalesce(quantity, 0)                  as decimal(18,2)) as quantity,
    cast(0                                      as decimal(18,2)) as unit_cost,
    cast(false                                  as boolean)       as is_under_warranty,
    cast(null as Nullable(DateTime64(3)))                         as created_at,
    cast(latest_extracted_at                as timestamp)     as _etl_loaded_at
from base
