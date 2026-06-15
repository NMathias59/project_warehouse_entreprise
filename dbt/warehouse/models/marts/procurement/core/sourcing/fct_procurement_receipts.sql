{{ config(materialized='table', engine='MergeTree()', order_by='(purchase_order_id, received_at)', settings={'allow_nullable_key': 1}, tags=['marts','procurement','fct']) }}
with receipts as (
    select
        id_receipt, reference, purchase_order_id, warehouse_id,
        status, received_by, received_at, created_at
    from {{ ref('stg_procurement__receipts') }}
),
lines as (
    select
        id_receipt_line, receipt_id, purchase_order_line_id,
        product_id, quantity_received, unit_cost, lot_number, created_at
    from {{ ref('stg_procurement__receipt_lines') }}
)
select
    l.id_receipt_line,
    l.receipt_id,
    r.reference,
    r.purchase_order_id,
    r.warehouse_id,
    r.status,
    r.received_by,
    r.received_at,
    l.purchase_order_line_id,
    l.product_id,
    l.quantity_received,
    l.unit_cost,
    l.lot_number,
    l.quantity_received * l.unit_cost                   as line_total_cost
from lines as l
left join receipts as r on r.id_receipt = l.receipt_id
