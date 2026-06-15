{{ config(materialized='view', tags=['staging', 'sirh']) }}

select
    id,
    argMax(code,            _airbyte_extracted_at) as code,
    argMax(name,            _airbyte_extracted_at) as name,
    argMax(parent_id,       _airbyte_extracted_at) as parent_department_id,
    argMax(manager_erp_ref, _airbyte_extracted_at) as manager_id,
    argMax(created_at,      _airbyte_extracted_at) as created_at,
    max(_airbyte_extracted_at)                    as latest_extracted_at
from {{ source('sirh', 'departments') }}
where id is not null
group by id
