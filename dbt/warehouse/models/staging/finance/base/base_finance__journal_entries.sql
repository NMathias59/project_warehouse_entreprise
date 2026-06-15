{{ config(materialized='view', tags=['staging', 'finance']) }}

select
    id,
    argMax(entry_number,    _airbyte_extracted_at) as entry_number,
    argMax(source,          _airbyte_extracted_at) as source,
    argMax(entry_date,      _airbyte_extracted_at) as entry_date,
    argMax(description,     _airbyte_extracted_at) as description,
    argMax(status,          _airbyte_extracted_at) as status,
    argMax(created_by,      _airbyte_extracted_at) as created_by,
    argMax(created_at,      _airbyte_extracted_at) as created_at,
    max(_airbyte_extracted_at)                    as latest_extracted_at
from {{ source('finance', 'journal_entries') }}
where id is not null
group by id
