{{ config(tags=['staging', 'marketing']) }}

with base as (

    select * from {{ ref('base_marketing__email_events') }}

)

select
    cast(id                              as varchar)   as id_email_event,
    cast(coalesce(send_id, '')           as varchar)   as send_id,
    cast(coalesce(event_type, '')        as varchar)   as event_type,
    cast(coalesce(event_url, '')         as varchar)   as event_url,
    cast(occurred_at                     as timestamp) as occurred_at,
    cast(occurred_at                     as timestamp) as created_at,
    cast(latest_extracted_at                as timestamp) as _etl_loaded_at
from base
