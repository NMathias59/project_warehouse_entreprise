{{ config(tags=['staging', 'mes']) }}

with source as (

    select * from {{ source('mes', 'material_consumptions') }}
    where id is not null

),

deduped as (

    select
        id,
        argMax(production_order_id, _airbyte_extracted_at) as production_order_id,
        argMax(component_id,        _airbyte_extracted_at) as component_id,
        argMax(quantity_planned,    _airbyte_extracted_at) as quantity_planned,
        argMax(quantity_consumed,   _airbyte_extracted_at) as quantity_consumed,
        argMax(unit_cost,           _airbyte_extracted_at) as unit_cost,
        argMax(lot_number,          _airbyte_extracted_at) as lot_number,
        argMax(consumed_at,         _airbyte_extracted_at) as consumed_at,
        argMax(created_at,          _airbyte_extracted_at) as created_at,
        max(_airbyte_extracted_at)                         as latest_extracted_at
    from source
    group by id

)

select
    cast(id                                     as varchar)       as id_material_consumption,
    cast(coalesce(production_order_id, '')      as varchar)       as production_order_id,
    cast(coalesce(component_id, '')             as varchar)       as component_id,
    cast(coalesce(quantity_planned, 0)          as decimal(18,2)) as quantity_planned,
    cast(coalesce(quantity_consumed, 0)         as decimal(18,2)) as quantity_consumed,
    cast(coalesce(unit_cost, 0)                 as decimal(18,2)) as unit_cost,
    cast(coalesce(lot_number, '')               as varchar)       as lot_number,
    cast(consumed_at                            as timestamp)     as consumed_at,
    cast(created_at                             as timestamp)     as created_at,
    cast(latest_extracted_at                    as timestamp)     as _etl_loaded_at
from deduped
