{{ config(materialized='view', tags=['intermediate', 'procurement']) }}

select
    pol.id_purchase_order_line,
    po.id_purchase_order,
    po.reference,
    po.status,
    po.supplier_id,
    any(s.name)                                                         as supplier_name,
    any(s.supplier_type)                                                as supplier_type,
    po.currency,
    po.sent_at,
    po.expected_delivery_at,
    pol.product_id,
    pol.description,
    pol.quantity_ordered,
    pol.quantity_received,
    pol.unit_price,
    pol.quantity_ordered * pol.unit_price                               as line_total,
    pol.quantity_received / nullIf(pol.quantity_ordered, 0)             as receipt_rate
from {{ ref('stg_procurement__purchase_orders') }} as po
left join {{ ref('stg_procurement__purchase_order_lines') }} as pol
    on pol.purchase_order_id = po.id_purchase_order
left join {{ ref('stg_procurement__suppliers') }} as s
    on s.id_supplier = po.supplier_id
group by
    pol.id_purchase_order_line,
    po.id_purchase_order,
    po.reference,
    po.status,
    po.supplier_id,
    po.currency,
    po.sent_at,
    po.expected_delivery_at,
    pol.product_id,
    pol.description,
    pol.quantity_ordered,
    pol.quantity_received,
    pol.unit_price
