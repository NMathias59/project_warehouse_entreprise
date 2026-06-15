{{ config(tags=['staging', 'mes']) }}

with source as (

    select * from {{ source('mes', 'material_consumptions') }}
    where id is not null

),

deduped as (

    select
        id,
        argMax(production_order_id, _airbyte_extracted_at) as production_order_id,
        argMax(component_sku,       _airbyte_extracted_at) as component_id,
        argMax(qty_issued,          _airbyte_extracted_at) as quantity_consumed,
        argMax(issued_at,           _airbyte_extracted_at) as consumed_at,
        max(_airbyte_extracted_at)                         as latest_extracted_at
    from source
    group by id

)

select
    cast(id                                     as varchar)       as id_material_consumption,
    cast(coalesce(production_order_id, '')      as varchar)       as production_order_id,
    cast(coalesce(component_id, '')             as varchar)       as component_id,
    cast(0                                      as decimal(18,2)) as quantity_planned,
    cast(coalesce(quantity_consumed, 0)         as decimal(18,2)) as quantity_consumed,
    cast(0                                      as decimal(18,2)) as unit_cost,
    cast(''                                     as varchar)       as lot_number,
    toDateTimeOrNull(toString(consumed_at))                       as consumed_at,
    cast(null as Nullable(DateTime64(3)))                         as created_at,
    cast(latest_extracted_at                    as timestamp)     as _etl_loaded_at
from deduped
