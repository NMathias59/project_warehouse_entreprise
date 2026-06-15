{{ config(materialized='view', tags=['staging', 'plm']) }}

select
    id,
    argMax(product_id,      _airbyte_extracted_at) as product_id,
    argMax(doc_type,        _airbyte_extracted_at) as document_type,
    argMax(title,           _airbyte_extracted_at) as title,
    argMax(file_path,       _airbyte_extracted_at) as file_reference,
    argMax(current_version, _airbyte_extracted_at) as version,
    argMax(status,          _airbyte_extracted_at) as status,
    argMax(author,          _airbyte_extracted_at) as created_by,
    argMax(created_at,      _airbyte_extracted_at) as created_at,
    max(_airbyte_extracted_at)                    as latest_extracted_at
from {{ source('plm', 'documents') }}
where id is not null
group by id
