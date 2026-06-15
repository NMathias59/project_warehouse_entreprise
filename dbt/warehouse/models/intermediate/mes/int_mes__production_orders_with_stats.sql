{{ config(materialized='view', tags=['intermediate', 'mes']) }}

select
    po.id_production_order                                                         as id_production_order,
    po.reference                                                                   as reference,
    po.status                                                                      as status,
    po.product_id                                                                  as product_id,
    po.work_center_id                                                              as work_center_id,
    po.quantity_planned                                                            as quantity_planned,
    po.quantity_produced                                                           as quantity_produced,
    po.quantity_scrapped                                                           as quantity_scrapped,
    po.planned_start_at                                                            as planned_start_at,
    po.actual_start_at                                                             as actual_start_at,
    po.actual_end_at                                                               as actual_end_at,
    count(distinct ops.id_production_operation)                                    as nb_operations,
    countIf(ops.status = 'completed')                                              as nb_ops_completed,
    sum(ops.setup_time_minutes)                                                    as total_setup_minutes,
    sum(ops.run_time_minutes)                                                      as total_run_minutes,
    sum(ops.actual_time_minutes)                                                   as total_actual_minutes,
    count(distinct d.id_defect)                                                    as nb_defects,
    sum(d.quantity_defective)                                                      as total_defective_qty,
    sum(mc.quantity_consumed * mc.unit_cost)                                       as total_material_cost,
    po.quantity_scrapped / nullIf(po.quantity_planned, 0)                          as scrap_rate,
    (po.quantity_produced - po.quantity_scrapped) / nullIf(po.quantity_planned, 0) as yield_rate
from {{ ref('stg_mes__production_orders') }} as po
left join {{ ref('stg_mes__production_operations') }} as ops
    on ops.production_order_id = po.id_production_order
left join {{ ref('stg_mes__defects') }} as d
    on d.production_order_id = po.id_production_order
left join {{ ref('stg_mes__material_consumptions') }} as mc
    on mc.production_order_id = po.id_production_order
group by
    id_production_order,
    reference,
    status,
    product_id,
    work_center_id,
    quantity_planned,
    quantity_produced,
    quantity_scrapped,
    planned_start_at,
    actual_start_at,
    actual_end_at
