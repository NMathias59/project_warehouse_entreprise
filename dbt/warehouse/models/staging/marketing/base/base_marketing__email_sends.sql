{{ config(materialized='view', tags=['staging', 'marketing']) }}

select
    id,
    argMax(campaign_id,    _airbyte_extracted_at) as campaign_id,
    argMax(email_address,  _airbyte_extracted_at) as recipient_email,
    argMax(status,         _airbyte_extracted_at) as status,
    argMax(sent_at,        _airbyte_extracted_at) as sent_at,
    max(_airbyte_extracted_at)                    as latest_extracted_at
from {{ source('marketing', 'email_sends') }}
where id is not null
group by id
