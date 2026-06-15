{{ config(materialized='view', tags=['staging', 'mes']) }}

select
    id,
    argMax(code,               _airbyte_extracted_at) as code,
    argMax(name,               _airbyte_extracted_at) as name,
    argMax(center_type,        _airbyte_extracted_at) as work_center_type,
    argMax(capacity_per_shift, _airbyte_extracted_at) as capacity_per_hour,
    argMax(is_active,          _airbyte_extracted_at) as is_active,
    argMax(created_at,         _airbyte_extracted_at) as created_at,
    max(_airbyte_extracted_at)                    as latest_extracted_at
from {{ source('mes', 'work_centers') }}
where id is not null
group by id
