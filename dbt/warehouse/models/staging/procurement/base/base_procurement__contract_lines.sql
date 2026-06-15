{{ config(materialized='view', tags=['staging', 'procurement']) }}

select
    id,
    argMax(contract_id,      _airbyte_extracted_at) as contract_id,
    argMax(component_sku,    _airbyte_extracted_at) as product_id,
    argMax(component_name,   _airbyte_extracted_at) as description,
    argMax(agreed_price_eur, _airbyte_extracted_at) as unit_price,
    argMax(min_qty,          _airbyte_extracted_at) as quantity_min,
    argMax(max_qty,          _airbyte_extracted_at) as quantity_max,
    max(_airbyte_extracted_at)                    as latest_extracted_at
from {{ source('procurement', 'contract_lines') }}
where id is not null
group by id
