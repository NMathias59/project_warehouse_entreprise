{{ config(materialized='table', engine='MergeTree()', order_by='(sent_at, supplier_id)', tags=['reports','procurement','sourcing']) }}
with po as (
    select
        id_purchase_order_line, purchase_order_id, reference, status,
        supplier_id, supplier_name, currency,
        quantity_ordered, quantity_received, unit_price, line_total,
        receipt_rate, expected_delivery_at, sent_at
    from {{ ref('fct_procurement_purchase_orders') }}
),
suppliers as (
    select id_supplier, name as supplier_name, supplier_type, country_code
    from {{ ref('dim_procurement_suppliers') }}
),
final as (
    select
        po.purchase_order_id,
        po.reference,
        po.status,
        po.supplier_id,
        coalesce(s.supplier_name, po.supplier_name)     as supplier_name,
        s.supplier_type,
        s.country_code,
        po.currency,
        sum(po.line_total)                              as total_ordered_amount,
        sum(po.quantity_ordered)                        as total_qty_ordered,
        sum(po.quantity_received)                       as total_qty_received,
        avg(po.receipt_rate)                            as avg_receipt_rate,
        min(po.expected_delivery_at)                    as expected_delivery_at,
        any(po.sent_at)                                 as sent_at
    from po
    left join suppliers as s on s.id_supplier = po.supplier_id
    group by
        po.purchase_order_id, po.reference, po.status,
        po.supplier_id, s.supplier_name, po.supplier_name,
        s.supplier_type, s.country_code, po.currency
)
select * from final
