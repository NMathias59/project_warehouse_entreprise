{{ config(tags=['staging', 'sav']) }}

with base as (

    select * from {{ ref('base_sav__ticket_history') }}

)

select
    cast(id                              as varchar)   as id_ticket_history,
    cast(coalesce(ticket_id, '')         as varchar)   as ticket_id,
    cast(coalesce(status_from, '')       as varchar)   as status_from,
    cast(coalesce(status_to, '')         as varchar)   as status_to,
    cast(coalesce(changed_by, '')        as varchar)   as changed_by,
    cast(changed_at                      as timestamp) as changed_at,
    cast(changed_at                      as timestamp) as created_at,
    cast(latest_extracted_at                as timestamp) as _etl_loaded_at
from base
