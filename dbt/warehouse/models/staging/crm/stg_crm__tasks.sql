{{ config(tags=['staging', 'crm']) }}

select
    cast(id                              as varchar)   as id_task,
    cast(coalesce(title, '')             as varchar)   as title,
    cast(coalesce(task_type, '')         as varchar)   as task_type,
    cast(coalesce(status, '')            as varchar)   as status,
    cast(coalesce(priority, '')          as varchar)   as priority,
    cast(coalesce(notes, '')             as varchar)   as notes,
    cast(coalesce(owner_id, '')          as varchar)   as owner_id,
    cast(coalesce(account_id, '')        as varchar)   as account_id,
    cast(coalesce(opportunity_id, '')    as varchar)   as opportunity_id,
    cast(due_at                          as timestamp) as due_at,
    cast(completed_at                    as timestamp) as completed_at,
    cast(created_at                      as timestamp) as created_at,
    cast(_airbyte_extracted_at           as timestamp) as _etl_loaded_at
from {{ source('crm', 'tasks') }}
where id is not null
