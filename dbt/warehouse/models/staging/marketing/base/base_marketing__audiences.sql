{{ config(materialized='view', tags=['staging', 'marketing']) }}

select
    id,
    argMax(name,           _airbyte_extracted_at) as name,
    argMax(description,    _airbyte_extracted_at) as description,
    argMax(audience_type,  _airbyte_extracted_at) as segment_type,
    argMax(criteria,       _airbyte_extracted_at) as criteria,
    argMax(member_count,   _airbyte_extracted_at) as estimated_size,
    argMax(is_active,      _airbyte_extracted_at) as is_active,
    argMax(created_at,     _airbyte_extracted_at) as created_at,
    max(_airbyte_extracted_at)                    as latest_extracted_at
from {{ source('marketing', 'audiences') }}
where id is not null
group by id
