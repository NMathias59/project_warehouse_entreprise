{{ config(materialized='view', tags=['staging', 'marketing']) }}

select
    id,
    argMax(send_id,     _airbyte_extracted_at) as send_id,
    argMax(event_type,  _airbyte_extracted_at) as event_type,
    argMax(event_meta,  _airbyte_extracted_at) as event_url,
    argMax(occurred_at, _airbyte_extracted_at) as occurred_at,
    max(_airbyte_extracted_at)                    as latest_extracted_at
from {{ source('marketing', 'email_events') }}
where id is not null
group by id
