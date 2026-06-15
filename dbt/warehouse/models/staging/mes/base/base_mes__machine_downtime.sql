{{ config(materialized='view', tags=['staging', 'mes']) }}

select
    id,
    argMax(work_center_id,   _airbyte_extracted_at) as work_center_id,
    argMax(cause_category,   _airbyte_extracted_at) as downtime_type,
    argMax(cause_detail,     _airbyte_extracted_at) as reason_code,
    argMax(started_at,       _airbyte_extracted_at) as started_at,
    argMax(ended_at,         _airbyte_extracted_at) as ended_at,
    argMax(duration_minutes, _airbyte_extracted_at) as duration_minutes,
    argMax(reported_by_ref,  _airbyte_extracted_at) as reported_by,
    argMax(created_at,       _airbyte_extracted_at) as created_at,
    max(_airbyte_extracted_at)                    as latest_extracted_at
from {{ source('mes', 'machine_downtime') }}
where id is not null
group by id
