{{ config(materialized='view', tags=['staging', 'wms']) }}

select
    id,
    argMax(session_id,    _airbyte_extracted_at) as session_id,
    argMax(product_sku,   _airbyte_extracted_at) as product_sku,
    argMax(location_id,   _airbyte_extracted_at) as location_id,
    argMax(qty_system,    _airbyte_extracted_at) as qty_system,
    argMax(qty_counted,   _airbyte_extracted_at) as qty_counted,
    argMax(variance,      _airbyte_extracted_at) as variance,
    argMax(counted_at,    _airbyte_extracted_at) as counted_at,
    max(_airbyte_extracted_at)                    as latest_extracted_at
from {{ source('wms', 'inventory_adjustments') }}
where id is not null
group by id
