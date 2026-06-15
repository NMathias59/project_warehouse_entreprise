{{ config(materialized='view', tags=['staging', 'qms']) }}

select
    id,
    argMax(supplier_ref,  _airbyte_extracted_at) as supplier_id,
    argMax(overall_score, _airbyte_extracted_at) as overall_score,
    argMax(created_at,    _airbyte_extracted_at) as created_at,
    argMax(updated_at,    _airbyte_extracted_at) as updated_at,
    max(_airbyte_extracted_at)                    as latest_extracted_at
from {{ source('qms', 'supplier_evaluations') }}
where id is not null
group by id
