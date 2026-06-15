{{ config(materialized='view', tags=['staging', 'plm']) }}

select
    id,
    argMax(product_id,     _airbyte_extracted_at) as product_id,
    argMax(revision,       _airbyte_extracted_at) as version_number,
    argMax(status,         _airbyte_extracted_at) as status,
    argMax(reason,         _airbyte_extracted_at) as change_summary,
    argMax(approved_by,    _airbyte_extracted_at) as approved_by,
    argMax(revision_date,  _airbyte_extracted_at) as effective_date,
    argMax(created_at,     _airbyte_extracted_at) as created_at,
    max(_airbyte_extracted_at)                    as latest_extracted_at
from {{ source('plm', 'product_versions') }}
where id is not null
group by id
