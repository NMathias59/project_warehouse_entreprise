{{ config(materialized='view', tags=['staging', 'sav']) }}

select
    id,
    argMax(rma_id,             _airbyte_extracted_at) as intervention_id,
    argMax(product_sku,        _airbyte_extracted_at) as part_reference,
    argMax(defect_description, _airbyte_extracted_at) as part_name,
    argMax(qty,                _airbyte_extracted_at) as quantity,
    max(_airbyte_extracted_at)                    as latest_extracted_at
from {{ source('sav', 'spare_parts_used') }}
where id is not null
group by id
