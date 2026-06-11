{{ config(
    materialized='table',
    engine='MergeTree()',
    order_by='(planned_at, id_work_order)',
    tags=['marts', 'erp', 'production']
) }}

select
    wo.id_work_order,
    wo.reference,
    wo.status,
    wo.quantity                                                         as qty_planned,
    wo.pc_model_id,
    pm.name                                                             as pc_model_name,
    pm.code                                                             as pc_model_code,
    wo.planned_at,
    wo.started_at,
    wo.completed_at,
    wo.created_at,
    count(wol.id_work_order_line)                                       as nb_components,
    coalesce(sum(wol.qty_planned), 0)                                   as total_qty_components_planned,
    coalesce(sum(wol.qty_consumed), 0)                                  as total_qty_components_consumed,
    if(wo.started_at > toDateTime('1970-01-01 00:00:00')
       and wo.completed_at > toDateTime('1970-01-01 00:00:00'),
       dateDiff('hour', wo.started_at, wo.completed_at),
       null)                                                            as duration_hours,
    multiIf(
        wo.status = 'done'
            and wo.completed_at > toDateTime('1970-01-01 00:00:00')
            and toDate(wo.completed_at) <= wo.planned_at,  'on_time',
        wo.status = 'done',                                            'completed_late',
        wo.status = 'in_progress'
            and toDate(now()) > wo.planned_at,             'overdue',
        wo.status
    )                                                                   as delivery_status
from {{ ref('stg_erp__work_orders') }} as wo
left join {{ ref('stg_erp__work_order_lines') }} as wol
    on wol.work_order_id = wo.id_work_order
left join {{ ref('stg_erp__pc_models') }} as pm
    on pm.id_pc_model = wo.pc_model_id
where wo.deleted_at = toDateTime('1970-01-01 00:00:00')
group by
    wo.id_work_order, wo.reference, wo.status, wo.quantity,
    wo.pc_model_id, pm.name, pm.code,
    wo.planned_at, wo.started_at, wo.completed_at, wo.created_at
