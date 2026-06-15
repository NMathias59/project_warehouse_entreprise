{{ config(materialized='view', tags=['staging', 'sav']) }}

select
    id,
    argMax(ticket_id,   _airbyte_extracted_at) as ticket_id,
    argMax(author_type, _airbyte_extracted_at) as sender_type,
    argMax(author_ref,  _airbyte_extracted_at) as sender_id,
    argMax(body,        _airbyte_extracted_at) as body,
    argMax(created_at,  _airbyte_extracted_at) as created_at,
    max(_airbyte_extracted_at)                    as latest_extracted_at
from {{ source('sav', 'ticket_messages') }}
where id is not null
group by id
