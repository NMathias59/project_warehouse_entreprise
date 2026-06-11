{{ config(tags=['staging', 'crm']) }}

select
    cast(id                              as varchar)   as id_pipeline_event,
    cast(coalesce(stage_from, '')        as varchar)   as stage_from,
    cast(coalesce(stage_to, '')          as varchar)   as stage_to,
    cast(coalesce(notes, '')             as varchar)   as notes,
    cast(coalesce(owner_id, '')          as varchar)   as owner_id,
    cast(coalesce(opportunity_id, '')    as varchar)   as opportunity_id,
    cast(occurred_at                     as timestamp) as occurred_at,
    cast(created_at                      as timestamp) as created_at,
    cast(_airbyte_extracted_at           as timestamp) as _etl_loaded_at
from {{ source('crm', 'pipeline_events') }}
where id is not null
