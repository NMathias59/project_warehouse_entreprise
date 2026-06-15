{{ config(materialized='view', tags=['staging', 'procurement']) }}

select
    id,
    argMax(supplier_id,    _airbyte_extracted_at) as supplier_id,
    argMax(quality_score,  _airbyte_extracted_at) as quality_score,
    argMax(delivery_score, _airbyte_extracted_at) as delivery_score,
    argMax(service_score,  _airbyte_extracted_at) as responsiveness_score,
    argMax(price_score,    _airbyte_extracted_at) as price_score,
    argMax(overall_score,  _airbyte_extracted_at) as overall_score,
    argMax(evaluator_ref,  _airbyte_extracted_at) as evaluated_by,
    argMax(created_at,     _airbyte_extracted_at) as created_at,
    max(_airbyte_extracted_at)                    as latest_extracted_at
from {{ source('procurement', 'supplier_evaluations') }}
where id is not null
group by id
