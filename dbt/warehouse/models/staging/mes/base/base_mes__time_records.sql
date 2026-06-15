{{ config(materialized='view', tags=['staging', 'mes']) }}

select
    id,
    argMax(job_card_id,  _airbyte_extracted_at) as operation_id,
    argMax(operator_id,  _airbyte_extracted_at) as operator_id,
    argMax(event_type,   _airbyte_extracted_at) as record_type,
    argMax(occurred_at,  _airbyte_extracted_at) as recorded_at,
    max(_airbyte_extracted_at)                    as latest_extracted_at
from {{ source('mes', 'time_records') }}
where id is not null
group by id
