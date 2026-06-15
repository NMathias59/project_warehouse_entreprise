{{ config(materialized='view', tags=['staging', 'plm']) }}

select
    id,
    argMax(code,             _airbyte_extracted_at) as code,
    argMax(name,             _airbyte_extracted_at) as name,
    argMax(description,      _airbyte_extracted_at) as description,
    argMax(family_id,        _airbyte_extracted_at) as product_family,
    argMax(lifecycle_status, _airbyte_extracted_at) as lifecycle_status,
    argMax(created_at,       _airbyte_extracted_at) as created_at,
    max(_airbyte_extracted_at)                    as latest_extracted_at
from {{ source('plm', 'products') }}
where id is not null
group by id
