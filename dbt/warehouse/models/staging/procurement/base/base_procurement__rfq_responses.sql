{{ config(materialized='view', tags=['staging', 'procurement']) }}

select
    id,
    argMax(rfq_id,         _airbyte_extracted_at) as rfq_id,
    argMax(supplier_id,    _airbyte_extracted_at) as supplier_id,
    argMax(unit_price_eur, _airbyte_extracted_at) as unit_price,
    argMax(lead_time_days, _airbyte_extracted_at) as lead_time_days,
    argMax(notes,          _airbyte_extracted_at) as notes,
    argMax(received_at,    _airbyte_extracted_at) as received_at,
    max(_airbyte_extracted_at)                    as latest_extracted_at
from {{ source('procurement', 'rfq_responses') }}
where id is not null
group by id
