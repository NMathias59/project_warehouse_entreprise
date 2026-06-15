{{ config(materialized='view', tags=['staging', 'mes']) }}

select
    id,
    argMax(step_number,      _airbyte_extracted_at) as sequence_number,
    argMax(name,             _airbyte_extracted_at) as operation_name,
    argMax(work_center_id,   _airbyte_extracted_at) as work_center_id,
    argMax(std_time_minutes, _airbyte_extracted_at) as run_time_minutes,
    max(_airbyte_extracted_at)                    as latest_extracted_at
from {{ source('mes', 'production_operations') }}
where id is not null
group by id
