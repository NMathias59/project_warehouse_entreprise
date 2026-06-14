{{ config(
    materialized='table',
    engine='MergeTree()',
    order_by='(supplier_id, week)',
    tags=['reports', 'wms', 'operations']
) }}

with receipts as (
    select
        supplier_id,
        warehouse_id,
        id_receipt,
        id_receipt_line,
        qty_expected,
        qty_received,
        received_at
    from {{ ref('fct_wms_receipts') }}
),

final as (
    select
        supplier_id,
        warehouse_id,
        toStartOfWeek(received_at)              as week,
        countDistinct(id_receipt)               as nb_receipts,
        count()                                 as nb_lines,
        sum(qty_expected)                       as total_qty_expected,
        sum(qty_received)                       as total_qty_received,
        sum(qty_received) / nullIf(sum(qty_expected), 0) as receipt_accuracy
    from receipts
    group by
        supplier_id,
        warehouse_id,
        week
)

select * from final
