{{ config(
    materialized='table',
    engine='MergeTree()',
    order_by='tuple()',
    tags=['bi', 'logistique']
) }}

select
    po.id_purchase_order,
    po.id_purchase_order_line,
    po.status                                                           as po_status,
    po.supplier_id,
    po.supplier_name,
    po.component_id,
    po.product_name                                                     as component_name,
    c.unit                                                              as component_unit,
    po.currency,
    po.quantity                                                         as qty_ordered,
    po.unit_price,
    po.line_total_ht,
    po.ordered_at,
    po.expected_at,
    dateDiff('day', po.ordered_at, po.expected_at)                     as lead_time_days,
    if(po.expected_at < now()
       and po.status not in ('received', 'cancelled'), 1, 0)           as is_late,
    coalesce(c.current_stock, 0)                                       as component_current_stock,
    coalesce(c.min_stock, 0)                                           as component_min_stock,
    coalesce(c.max_stock, 0)                                           as component_max_stock,
    if(coalesce(c.current_stock, 0) <= coalesce(c.min_stock, 0)
       and coalesce(c.min_stock, 0) > 0, 1, 0)                       as component_below_min,
    if(coalesce(c.current_stock, 0) > 0,
       ceil(coalesce(c.current_stock, 0) / nullIf(po.quantity, 0)), null) as stock_covers_n_orders
from {{ ref('fct_purchase_orders') }} as po
left join {{ ref('dim_components') }} as c
    on c.id_component = po.component_id
