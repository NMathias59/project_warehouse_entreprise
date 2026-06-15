{{ config(materialized='view', tags=['staging', 'finance']) }}

select
    id,
    argMax(code,           _airbyte_extracted_at) as code,
    argMax(name,           _airbyte_extracted_at) as name,
    argMax(department_ref, _airbyte_extracted_at) as department_ref,
    argMax(is_active,      _airbyte_extracted_at) as is_active,
    max(_airbyte_extracted_at)                    as latest_extracted_at
from {{ source('finance', 'cost_centers') }}
where id is not null
group by id
