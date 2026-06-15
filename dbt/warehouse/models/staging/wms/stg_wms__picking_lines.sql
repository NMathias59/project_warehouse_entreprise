{{ config(tags=['staging', 'wms']) }}

select
    cast(id                                                                          as varchar)       as id_picking_line,
    cast(coalesce(argMax(pick_order_id,    _airbyte_extracted_at), '')               as varchar)       as picking_order_id,
    cast(coalesce(argMax(product_sku,      _airbyte_extracted_at), '')               as varchar)       as product_id,
    cast(coalesce(argMax(from_location_id, _airbyte_extracted_at), '')               as varchar)       as location_id,
    cast(coalesce(argMax(qty_requested,    _airbyte_extracted_at), 0)                as decimal(18,2)) as quantity_requested,
    cast(coalesce(argMax(qty_picked,       _airbyte_extracted_at), 0)                as decimal(18,2)) as quantity_picked,
    cast(argMax(status, _airbyte_extracted_at) = 'completed'                         as boolean)       as is_completed,
    toDateTimeOrNull(toString(argMax(picked_at, _airbyte_extracted_at)))                               as picked_at,
    cast(max(_airbyte_extracted_at)                                                  as timestamp)     as created_at,
    cast(max(_airbyte_extracted_at)                                                  as timestamp)     as _etl_loaded_at
from {{ source('wms', 'picking_lines') }}
where id is not null
group by id
