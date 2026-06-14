{{ config(materialized='ephemeral', tags=['intermediate', 'wms']) }}

with picking_orders as (
    select * from {{ ref('stg_wms__picking_orders') }}
),

picking_lines as (
    select * from {{ ref('stg_wms__picking_lines') }}
)

select
    po.id_picking_order,
    po.reference,
    po.status,
    po.shipment_id,
    po.warehouse_id,
    po.assigned_to,
    po.started_at,
    po.completed_at,
    count(pl.id_picking_line)                                                       as nb_lines,
    countIf(pl.is_completed)                                                        as nb_lines_completed,
    sum(pl.quantity_requested)                                                      as total_qty_requested,
    sum(pl.quantity_picked)                                                         as total_qty_picked,
    sum(pl.quantity_picked) / nullIf(sum(pl.quantity_requested), 0)                 as completion_rate,
    dateDiff('minute', po.started_at, po.completed_at)                             as duration_minutes
from picking_orders as po
left join picking_lines as pl
    on pl.picking_order_id = po.id_picking_order
group by
    po.id_picking_order,
    po.reference,
    po.status,
    po.shipment_id,
    po.warehouse_id,
    po.assigned_to,
    po.started_at,
    po.completed_at
