{{ config(tags=['staging', 'crm']) }}

select
    cast(id                                  as varchar)   as id_activity,
    cast(coalesce(activity_type, '')         as varchar)   as activity_type,
    cast(coalesce(subject, '')               as varchar)   as subject,
    cast(coalesce(body, '')                  as varchar)   as body,
    cast(coalesce(outcome, '')               as varchar)   as outcome,
    cast(coalesce(direction, '')             as varchar)   as direction,
    cast(coalesce(owner_id, '')              as varchar)   as owner_id,
    cast(coalesce(account_id, '')            as varchar)   as account_id,
    cast(coalesce(contact_id, '')            as varchar)   as contact_id,
    cast(coalesce(opportunity_id, '')        as varchar)   as opportunity_id,
    coalesce(duration_minutes, 0)                         as duration_minutes,
    cast(occurred_at                         as timestamp) as occurred_at,
    cast(created_at                          as timestamp) as created_at,
    cast(_airbyte_extracted_at               as timestamp) as _etl_loaded_at
from {{ source('crm', 'activities') }}
where id is not null
