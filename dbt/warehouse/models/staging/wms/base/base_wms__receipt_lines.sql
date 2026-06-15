{{ config(materialized='view', tags=['staging', 'wms']) }}

select
    id,
    argMax(receipt_id,      _airbyte_extracted_at) as receipt_id,
    argMax(product_sku,     _airbyte_extracted_at) as product_sku,
    argMax(put_location_id, _airbyte_extracted_at) as put_location_id,
    argMax(qty_expected,    _airbyte_extracted_at) as qty_expected,
    argMax(qty_received,    _airbyte_extracted_at) as qty_received,
    argMax(lot_number,      _airbyte_extracted_at) as lot_number,
    argMax(created_at,      _airbyte_extracted_at) as created_at,
    max(_airbyte_extracted_at)                    as latest_extracted_at
from {{ source('wms', 'receipt_lines') }}
where id is not null
group by id
