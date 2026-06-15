{{ config(tags=['staging', 'mes']) }}

with base as (

    select * from {{ ref('base_mes__material_consumptions') }}

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
    cast(latest_extracted_at                as timestamp)     as _etl_loaded_at
from base
