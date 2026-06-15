{{ config(materialized='view', tags=['staging', 'sav']) }}

select
    id,
    argMax(ticket_id,   _airbyte_extracted_at) as ticket_id,
    argMax(old_value,   _airbyte_extracted_at) as status_from,
    argMax(new_value,   _airbyte_extracted_at) as status_to,
    argMax(actor_ref,   _airbyte_extracted_at) as changed_by,
    argMax(occurred_at, _airbyte_extracted_at) as changed_at,
    max(_airbyte_extracted_at)                    as latest_extracted_at
from {{ source('sav', 'ticket_history') }}
where id is not null
group by id
