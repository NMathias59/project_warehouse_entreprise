{{ config(materialized='view', tags=['staging', 'plm']) }}

select
    id,
    argMax(product_revision_id, _airbyte_extracted_at) as product_version_id,
    argMax(status,              _airbyte_extracted_at) as status,
    argMax(created_at,          _airbyte_extracted_at) as created_at,
    max(_airbyte_extracted_at)                    as latest_extracted_at
from {{ source('plm', 'bom_headers') }}
where id is not null
group by id
