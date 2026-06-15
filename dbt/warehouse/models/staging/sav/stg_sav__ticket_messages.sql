{{ config(tags=['staging', 'sav']) }}

with base as (

    select * from {{ ref('base_sav__ticket_messages') }}

)

select
    cast(id                                 as varchar)   as id_ticket_message,
    cast(coalesce(ticket_id, '')            as varchar)   as ticket_id,
    cast(coalesce(sender_type, '')          as varchar)   as sender_type,
    cast(coalesce(sender_id, '')            as varchar)   as sender_id,
    cast(coalesce(body, '')                 as varchar)   as body,
    cast(false                              as boolean)   as has_attachment,
    cast(created_at                         as timestamp) as sent_at,
    cast(created_at                         as timestamp) as created_at,
    cast(latest_extracted_at                as timestamp) as _etl_loaded_at
from base
