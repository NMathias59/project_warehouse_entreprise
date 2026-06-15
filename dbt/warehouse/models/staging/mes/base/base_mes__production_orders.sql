{{ config(materialized='view', tags=['staging', 'mes']) }}

select
    id,
    argMax(order_number,  _airbyte_extracted_at) as reference,
    argMax(status,        _airbyte_extracted_at) as status,
    argMax(product_sku,   _airbyte_extracted_at) as product_id,
    argMax(qty_planned,   _airbyte_extracted_at) as quantity_planned,
    argMax(qty_completed, _airbyte_extracted_at) as quantity_produced,
    argMax(qty_scrapped,  _airbyte_extracted_at) as quantity_scrapped,
    argMax(planned_start, _airbyte_extracted_at) as planned_start_at,
    argMax(planned_end,   _airbyte_extracted_at) as planned_end_at,
    argMax(actual_start,  _airbyte_extracted_at) as actual_start_at,
    argMax(actual_end,    _airbyte_extracted_at) as actual_end_at,
    argMax(created_at,    _airbyte_extracted_at) as created_at,
    max(_airbyte_extracted_at)                    as latest_extracted_at
from {{ source('mes', 'production_orders') }}
where id is not null
group by id
