{{ config(materialized='view', tags=['staging', 'wms']) }}

select
    id,
    argMax(transfer_order_id, _airbyte_extracted_at) as transfer_order_id,
    argMax(product_sku,       _airbyte_extracted_at) as product_sku,
    argMax(to_location_id,    _airbyte_extracted_at) as to_location_id,
    argMax(qty,               _airbyte_extracted_at) as qty,
    argMax(moved_at,          _airbyte_extracted_at) as moved_at,
    max(_airbyte_extracted_at)                    as latest_extracted_at
from {{ source('wms', 'shipment_lines') }}
where id is not null
group by id
