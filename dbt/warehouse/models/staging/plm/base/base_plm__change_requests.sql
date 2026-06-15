{{ config(materialized='view', tags=['staging', 'plm']) }}

select
    id,
    argMax(eco_number,           _airbyte_extracted_at) as reference,
    argMax(title,                _airbyte_extracted_at) as title,
    argMax(description,          _airbyte_extracted_at) as description,
    argMax(product_id,           _airbyte_extracted_at) as product_id,
    argMax(priority,             _airbyte_extracted_at) as priority,
    argMax(status,               _airbyte_extracted_at) as status,
    argMax(requested_by,         _airbyte_extracted_at) as requested_by,
    argMax(approved_by,          _airbyte_extracted_at) as approved_by,
    argMax(implementation_date,  _airbyte_extracted_at) as implemented_at,
    argMax(created_at,           _airbyte_extracted_at) as created_at,
    max(_airbyte_extracted_at)                    as latest_extracted_at
from {{ source('plm', 'change_requests') }}
where id is not null
group by id
