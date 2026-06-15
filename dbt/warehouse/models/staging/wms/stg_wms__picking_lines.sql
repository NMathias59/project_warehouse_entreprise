{{ config(tags=['staging', 'wms']) }}

with base as (

    select * from {{ ref('base_wms__picking_lines') }}

)

select
    cast(id                                          as varchar)       as id_picking_line,
    cast(coalesce(pick_order_id,    '')              as varchar)       as picking_order_id,
    cast(coalesce(product_sku,      '')              as varchar)       as product_id,
    cast(coalesce(from_location_id, '')              as varchar)       as location_id,
    cast(coalesce(qty_requested,    0)               as decimal(18,2)) as quantity_requested,
    cast(coalesce(qty_picked,       0)               as decimal(18,2)) as quantity_picked,
    cast(status = 'completed'                        as boolean)       as is_completed,
    toDateTimeOrNull(toString(picked_at))                              as picked_at,
    cast(latest_extracted_at                as timestamp)     as created_at,
    cast(latest_extracted_at                as timestamp)     as _etl_loaded_at
from base
