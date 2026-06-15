{{ config(materialized='view', tags=['staging', 'procurement']) }}

select
    id,
    argMax(supplier_id, _airbyte_extracted_at) as supplier_id,
    argMax(name,        _airbyte_extracted_at) as first_name,
    argMax(email,       _airbyte_extracted_at) as email,
    argMax(phone,       _airbyte_extracted_at) as phone,
    argMax(role,        _airbyte_extracted_at) as role,
    argMax(is_primary,  _airbyte_extracted_at) as is_primary,
    max(_airbyte_extracted_at)                    as latest_extracted_at
from {{ source('procurement', 'supplier_contacts') }}
where id is not null
group by id
