{{ config(materialized='table', engine='MergeTree()', order_by='(sent_at, supplier_id)', settings={'allow_nullable_key': 1}, tags=['reports','procurement','sourcing']) }}

select
    po.id_purchase_order                                            as id_purchase_order,
    any(po.reference)                                               as reference,
    any(po.status)                                                  as status,
    po.supplier_id                                                  as supplier_id,
    any(coalesce(s.name, po.supplier_name))                         as supplier_name,
    any(s.supplier_type)                                            as supplier_type,
    any(s.country_code)                                             as country_code,
    any(po.currency)                                                as currency,
    sum(po.line_total)                                              as total_ordered_amount,
    sum(po.quantity_ordered)                                        as total_qty_ordered,
    sum(po.quantity_received)                                       as total_qty_received,
    avg(po.receipt_rate)                                            as avg_receipt_rate,
    min(po.expected_delivery_at)                                    as expected_delivery_at,
    any(po.sent_at)                                                 as sent_at
from {{ ref('fct_procurement_purchase_orders') }} as po
left join {{ ref('dim_procurement_suppliers') }} as s
    on s.id_supplier = po.supplier_id
group by
    id_purchase_order,
    supplier_id
