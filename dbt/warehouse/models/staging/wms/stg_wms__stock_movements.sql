{{ config(tags=['staging', 'wms']) }}

with base as (

    select * from {{ ref('base_wms__stock_movements') }}

)

select
    cast(id                          as varchar)       as id_stock_movement,
    cast(''                          as varchar)       as reference,
    cast('position'                  as varchar)       as movement_type,
    cast(coalesce(product_sku,  '')  as varchar)       as product_id,
    cast(coalesce(location_id,  '')  as varchar)       as location_id,
    cast(''                          as varchar)       as warehouse_id,
    cast(''                          as varchar)       as source_document_id,
    cast(coalesce(qty_on_hand,  0)   as decimal(18,2)) as quantity,
    cast(0                           as decimal(18,2)) as unit_cost,
    toDateTimeOrNull(toString(updated_at))             as moved_at,
    cast(''                          as varchar)       as created_by,
    cast(latest_extracted_at                as timestamp)     as created_at,
    cast(latest_extracted_at                as timestamp)     as _etl_loaded_at
from base
