{{ config(materialized='view', tags=['staging', 'finance']) }}

select
    id,
    argMax(account_number, _airbyte_extracted_at) as account_number,
    argMax(name,           _airbyte_extracted_at) as name,
    argMax(account_type,   _airbyte_extracted_at) as account_type,
    argMax(parent_id,      _airbyte_extracted_at) as parent_id,
    argMax(is_active,      _airbyte_extracted_at) as is_active,
    argMax(created_at,     _airbyte_extracted_at) as created_at,
    max(_airbyte_extracted_at)                    as latest_extracted_at
from {{ source('finance', 'accounts') }}
where id is not null
group by id
