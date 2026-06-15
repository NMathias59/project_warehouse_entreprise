{{ config(tags=['staging', 'marketing']) }}

with source as (

    select * from {{ source('marketing', 'email_events') }}
    where id is not null

),

deduped as (

    select
        id,
        argMax(send_id,     _airbyte_extracted_at) as send_id,
        argMax(event_type,  _airbyte_extracted_at) as event_type,
        argMax(event_meta,  _airbyte_extracted_at) as event_url,
        argMax(occurred_at, _airbyte_extracted_at) as occurred_at,
        max(_airbyte_extracted_at)                 as latest_extracted_at
    from source
    group by id

)

select
    cast(id                              as varchar)   as id_email_event,
    cast(coalesce(send_id, '')           as varchar)   as send_id,
    cast(coalesce(event_type, '')        as varchar)   as event_type,
    cast(coalesce(event_url, '')         as varchar)   as event_url,
    cast(occurred_at                     as timestamp) as occurred_at,
    cast(occurred_at                     as timestamp) as created_at,
    cast(latest_extracted_at             as timestamp) as _etl_loaded_at
from deduped
