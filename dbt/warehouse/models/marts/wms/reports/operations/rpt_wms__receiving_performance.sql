{{ config(
    materialized='table',
    engine='MergeTree()',
    order_by='(supplier_id, week)',
    settings={'allow_nullable_key': 1},
    tags=['reports', 'wms', 'operations']
) }}

with receipts as (
    select
        supplier_id,
        warehouse_id,
        id_receipt,
        id_receipt_line,
        quantity_expected,
        quantity_received,
        received_at
    from {{ ref('fct_wms_receipts') }}
    where received_at is not null
),

final as (
    select
        supplier_id,
        warehouse_id,
        toStartOfWeek(received_at)              as week,
        countDistinct(id_receipt)               as nb_receipts,
        count()                                 as nb_lines,
        sum(quantity_expected)                       as total_qty_expected,
        sum(quantity_received)                       as total_qty_received,
        sum(quantity_received) / nullIf(sum(quantity_expected), 0) as receipt_accuracy
    from receipts
    group by
        supplier_id,
        warehouse_id,
        week
)

select * from final
