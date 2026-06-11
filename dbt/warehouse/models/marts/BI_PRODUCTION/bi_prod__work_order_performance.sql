{{ config(
    materialized='table',
    engine='MergeTree()',
    order_by='(planned_month, pc_model_id)',
    tags=['bi', 'production']
) }}

select
    toYYYYMM(planned_at)                                                as planned_month,
    pc_model_id,
    pc_model_name,
    count(id_work_order)                                                as total_work_orders,
    countIf(status = 'done')                                            as completed_count,
    countIf(status = 'in_progress')                                     as in_progress_count,
    countIf(delivery_status = 'on_time')                                as on_time_count,
    countIf(delivery_status = 'completed_late')                         as late_count,
    countIf(delivery_status = 'overdue')                                as overdue_count,
    sum(qty_planned)                                                    as total_qty_planned,
    if(count(id_work_order) > 0,
       round(countIf(status = 'done') * 100.0 / count(id_work_order), 2),
       0)                                                               as completion_rate_pct,
    if(countIf(status = 'done') > 0,
       round(countIf(delivery_status = 'on_time') * 100.0
             / countIf(status = 'done'), 2),
       0)                                                               as on_time_rate_pct,
    round(avg(duration_hours), 1)                                       as avg_duration_hours,
    round(avg(
        if(total_qty_components_planned > 0,
           total_qty_components_consumed * 100.0 / total_qty_components_planned,
           null)
    ), 2)                                                               as avg_component_consumption_rate_pct
from {{ ref('fct_work_orders') }}
where planned_at is not null
group by toYYYYMM(planned_at), pc_model_id, pc_model_name
