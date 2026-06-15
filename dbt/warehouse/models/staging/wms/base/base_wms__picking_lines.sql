{{ config(materialized='view', tags=['staging', 'wms']) }}

select
    id,
    argMax(pick_order_id,    _airbyte_extracted_at) as pick_order_id,
    argMax(product_sku,      _airbyte_extracted_at) as product_sku,
    argMax(from_location_id, _airbyte_extracted_at) as from_location_id,
    argMax(qty_requested,    _airbyte_extracted_at) as qty_requested,
    argMax(qty_picked,       _airbyte_extracted_at) as qty_picked,
    argMax(status,           _airbyte_extracted_at) as status,
    argMax(picked_at,        _airbyte_extracted_at) as picked_at,
    max(_airbyte_extracted_at)                    as latest_extracted_at
from {{ source('wms', 'picking_lines') }}
where id is not null
group by id
