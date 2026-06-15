{{ config(materialized='view', tags=['staging', 'wms']) }}

select
    id,
    argMax(product_sku,  _airbyte_extracted_at) as product_sku,
    argMax(location_id,  _airbyte_extracted_at) as location_id,
    argMax(qty_on_hand,  _airbyte_extracted_at) as qty_on_hand,
    argMax(updated_at,   _airbyte_extracted_at) as updated_at,
    max(_airbyte_extracted_at)                    as latest_extracted_at
from {{ source('wms', 'stock_movements') }}
where id is not null
group by id
