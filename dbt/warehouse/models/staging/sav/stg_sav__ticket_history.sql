{{ config(tags=['staging', 'sav']) }}

with source as (

    select * from {{ source('sav', 'ticket_history') }}
    where id is not null

),

deduped as (

    select
        id,
        argMax(ticket_id,    _airbyte_extracted_at) as ticket_id,
        argMax(status_from,  _airbyte_extracted_at) as status_from,
        argMax(status_to,    _airbyte_extracted_at) as status_to,
        argMax(changed_by,   _airbyte_extracted_at) as changed_by,
        argMax(changed_at,   _airbyte_extracted_at) as changed_at,
        argMax(created_at,   _airbyte_extracted_at) as created_at,
        max(_airbyte_extracted_at)                  as latest_extracted_at
    from source
    group by id

)

select
    cast(id                              as varchar)   as id_ticket_history,
    cast(coalesce(ticket_id, '')         as varchar)   as ticket_id,
    cast(coalesce(status_from, '')       as varchar)   as status_from,
    cast(coalesce(status_to, '')         as varchar)   as status_to,
    cast(coalesce(changed_by, '')        as varchar)   as changed_by,
    cast(changed_at                      as timestamp) as changed_at,
    cast(created_at                      as timestamp) as created_at,
    cast(latest_extracted_at             as timestamp) as _etl_loaded_at
from deduped
