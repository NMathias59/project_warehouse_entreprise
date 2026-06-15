{{ config(materialized='view', tags=['staging', 'wms']) }}

select
    id,
    argMax(pick_order_number,     _airbyte_extracted_at) as pick_order_number,
    argMax(status,                _airbyte_extracted_at) as status,
    argMax(marketplace_order_ref, _airbyte_extracted_at) as marketplace_order_ref,
    argMax(assigned_to_ref,       _airbyte_extracted_at) as assigned_to_ref,
    argMax(started_at,            _airbyte_extracted_at) as started_at,
    argMax(completed_at,          _airbyte_extracted_at) as completed_at,
    argMax(created_at,            _airbyte_extracted_at) as created_at,
    max(_airbyte_extracted_at)                    as latest_extracted_at
from {{ source('wms', 'picking_orders') }}
where id is not null
group by id
