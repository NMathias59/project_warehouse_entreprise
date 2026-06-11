{{ config(
    materialized='table',
    engine='MergeTree()',
    order_by='(created_at, id_task)',
    tags=['marts', 'crm', 'fct']
) }}

select
    id_task,
    title,
    task_type,
    status,
    priority,
    owner_id,
    account_id,
    opportunity_id,
    due_at,
    completed_at,
    created_at,
    if(status = 'done', 1, 0)                                               as is_completed,
    if(completed_at is not null and due_at is not null
       and completed_at <= due_at, 1, 0)                                    as is_on_time,
    if(status != 'done' and due_at < now(), 1, 0)                           as is_overdue
from {{ ref('stg_crm__tasks') }}
