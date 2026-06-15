{{ config(materialized='view', tags=['staging', 'mes']) }}

select
    id,
    argMax(production_order_id, _airbyte_extracted_at) as production_order_id,
    argMax(component_sku,       _airbyte_extracted_at) as component_id,
    argMax(qty_issued,          _airbyte_extracted_at) as quantity_consumed,
    argMax(issued_at,           _airbyte_extracted_at) as consumed_at,
    max(_airbyte_extracted_at)                    as latest_extracted_at
from {{ source('mes', 'material_consumptions') }}
where id is not null
group by id
