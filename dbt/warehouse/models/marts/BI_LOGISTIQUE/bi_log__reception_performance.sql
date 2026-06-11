{{ config(
    materialized='table',
    engine='MergeTree()',
    order_by='tuple()',
    tags=['bi', 'logistique']
) }}

with po_receipts as (

    select
        po.id_purchase_order,
        po.supplier_id,
        po.supplier_name,
        po.component_id,
        po.product_name                                                  as component_name,
        po.currency,
        po.ordered_at,
        po.expected_at,
        po.quantity                                                      as qty_ordered,
        po.line_total_ht,
        po.status                                                        as po_status,
        r.received_at,
        r.quantity                                                       as qty_received,
        r.condition                                                      as receipt_condition
    from {{ ref('fct_purchase_orders') }} as po
    left join {{ ref('fct_purchase_receipt') }} as r
        on  r.purchase_order_id = po.id_purchase_order
        and r.component_id      = po.component_id

),

-- Agrégation séparée pour éviter le bug ClickHouse alias-dans-même-SELECT
aggregated as (

    select
        id_purchase_order,
        supplier_id,
        supplier_name,
        component_id,
        component_name,
        currency,
        ordered_at,
        expected_at,
        po_status,
        qty_ordered,
        line_total_ht,
        coalesce(sum(qty_received), 0)                                   as sum_qty_received,
        countIf(receipt_condition = 'good')                              as receipts_good,
        countIf(receipt_condition != 'good'
                and receipt_condition != '')                             as receipts_defective,
        minIf(received_at,
              received_at > toDateTime('1970-01-01 00:00:00'))           as first_received_at,
        maxIf(received_at,
              received_at > toDateTime('1970-01-01 00:00:00'))           as last_received_at
    from po_receipts
    group by
        id_purchase_order,
        supplier_id,
        supplier_name,
        component_id,
        component_name,
        currency,
        ordered_at,
        expected_at,
        po_status,
        qty_ordered,
        line_total_ht

)

select
    id_purchase_order,
    supplier_id,
    supplier_name,
    component_id,
    component_name,
    currency,
    ordered_at,
    expected_at,
    po_status,
    qty_ordered,
    line_total_ht,
    sum_qty_received                                                     as qty_received,
    round(sum_qty_received * 100.0 / nullIf(qty_ordered, 0), 2)         as fill_rate_pct,
    receipts_good,
    receipts_defective,
    first_received_at,
    last_received_at,
    if(
        first_received_at > toDateTime('1970-01-01 00:00:00')
        and expected_at > toDateTime('1970-01-01 00:00:00'),
        dateDiff('day', toDate(expected_at), toDate(first_received_at)),
        null
    )                                                                    as reception_delay_days,
    if(
        first_received_at > toDateTime('1970-01-01 00:00:00')
        and expected_at > toDateTime('1970-01-01 00:00:00')
        and toDate(first_received_at) > toDate(expected_at),
        1, 0
    )                                                                    as is_late_reception
from aggregated
