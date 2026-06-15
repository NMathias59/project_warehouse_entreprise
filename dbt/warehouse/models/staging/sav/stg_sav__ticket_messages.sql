{{ config(tags=['staging', 'sav']) }}

with source as (

    select * from {{ source('sav', 'ticket_messages') }}
    where id is not null

),

deduped as (

    select
        id,
        argMax(ticket_id,   _airbyte_extracted_at) as ticket_id,
        argMax(author_type, _airbyte_extracted_at) as sender_type,
        argMax(author_ref,  _airbyte_extracted_at) as sender_id,
        argMax(body,        _airbyte_extracted_at) as body,
        argMax(created_at,  _airbyte_extracted_at) as created_at,
        max(_airbyte_extracted_at)                 as latest_extracted_at
    from source
    group by id

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
from deduped
