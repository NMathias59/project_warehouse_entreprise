{{ config(materialized='ephemeral', tags=['intermediate', 'wms']) }}

with receipts as (
    select * from {{ ref('stg_wms__receipts') }}
),

receipt_lines as (
    select * from {{ ref('stg_wms__receipt_lines') }}
)

select
    rl.id_receipt_line,
    r.id_receipt,
    r.reference,
    r.status,
    r.supplier_id,
    r.warehouse_id,
    r.purchase_order_id,
    r.received_at,
    rl.product_id,
    rl.location_id,
    rl.quantity_expected,
    rl.quantity_received,
    rl.unit_cost,
    rl.lot_number,
    rl.expiry_date,
    rl.quantity_received * rl.unit_cost                              as line_total_cost
from receipts as r
left join receipt_lines as rl
    on rl.receipt_id = r.id_receipt
