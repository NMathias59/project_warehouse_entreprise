{{ config(materialized='ephemeral', tags=['intermediate', 'mes']) }}

with production_orders as (
    select * from {{ ref('stg_mes__production_orders') }}
),

production_operations as (
    select * from {{ ref('stg_mes__production_operations') }}
),

defects as (
    select * from {{ ref('stg_mes__defects') }}
),

material_consumptions as (
    select * from {{ ref('stg_mes__material_consumptions') }}
)

select
    po.id_production_order,
    po.reference,
    po.status,
    po.product_id,
    po.quantity_planned,
    po.quantity_produced,
    po.quantity_scrapped,
    po.planned_start_at,
    po.actual_start_at,
    po.actual_end_at,
    count(distinct ops.id_production_operation)                                         as nb_operations,
    countIf(ops.status = 'completed')                                                   as nb_ops_completed,
    sum(ops.setup_time_minutes)                                                         as total_setup_minutes,
    sum(ops.run_time_minutes)                                                           as total_run_minutes,
    sum(ops.actual_time_minutes)                                                        as total_actual_minutes,
    count(distinct d.id_defect)                                                         as nb_defects,
    sum(d.quantity_defective)                                                           as total_defective_qty,
    sum(mc.quantity_consumed * mc.unit_cost)                                            as total_material_cost,
    po.quantity_scrapped / nullIf(po.quantity_planned, 0)                               as scrap_rate,
    (po.quantity_produced - po.quantity_scrapped) / nullIf(po.quantity_planned, 0)      as yield_rate
from production_orders as po
left join production_operations as ops
    on ops.production_order_id = po.id_production_order
left join defects as d
    on d.production_order_id = po.id_production_order
left join material_consumptions as mc
    on mc.production_order_id = po.id_production_order
group by
    po.id_production_order,
    po.reference,
    po.status,
    po.product_id,
    po.quantity_planned,
    po.quantity_produced,
    po.quantity_scrapped,
    po.planned_start_at,
    po.actual_start_at,
    po.actual_end_at
