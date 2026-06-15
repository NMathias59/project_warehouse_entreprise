{{ config(materialized='view', tags=['staging', 'marketing']) }}

select
    id,
    argMax(name,          _airbyte_extracted_at) as name,
    argMax(campaign_type, _airbyte_extracted_at) as campaign_type,
    argMax(status,        _airbyte_extracted_at) as status,
    argMax(channel,       _airbyte_extracted_at) as channel,
    argMax(audience_id,   _airbyte_extracted_at) as target_audience,
    argMax(scheduled_at,  _airbyte_extracted_at) as started_at,
    argMax(sent_at,       _airbyte_extracted_at) as ended_at,
    argMax(created_at,    _airbyte_extracted_at) as created_at,
    argMax(updated_at,    _airbyte_extracted_at) as updated_at,
    max(_airbyte_extracted_at)                    as latest_extracted_at
from {{ source('marketing', 'campaigns') }}
where id is not null
group by id
