{{ config(
    materialized='table',
    engine='MergeTree()',
    order_by='(ordered_at, id_purchase_order)',
    settings={'allow_nullable_key': 1},
    tags=['bi', 'achats']
) }}

with po_summary as (
    select
        id_purchase_order,
        any(status)                     as status,
        any(currency)                   as currency,
        any(ordered_at)                 as ordered_at,
        any(expected_at)                as expected_at,
        any(supplier_id)                as supplier_id,
        any(supplier_name)              as supplier_name,
        count(id_purchase_order_line)   as nb_lines,
        sum(quantity)                   as quantity_ordered,
        sum(line_total_ht)              as total_ht
    from {{ ref('fct_purchase_orders') }}
    group by id_purchase_order
),

receipt_summary as (
    select
        purchase_order_id,
        min(received_at)                as first_received_at,
        max(received_at)                as last_received_at,
        sum(quantity)                   as quantity_received
    from {{ ref('fct_purchase_receipt') }}
    group by purchase_order_id
),

invoice_summary as (
    select
        purchase_order_id,
        count(id_vendor_invoice)        as nb_invoices,
        sum(total_ht)                   as invoiced_ht,
        countIf(status = 'paid')        as nb_invoices_paid,
        countIf(status = 'overdue')     as nb_invoices_overdue
    from {{ ref('fct_vendor_invoice') }}
    group by purchase_order_id
)

select
    po.id_purchase_order,
    po.status,
    po.currency,
    po.ordered_at,
    po.expected_at,
    po.supplier_id,
    po.supplier_name,
    po.nb_lines,
    po.quantity_ordered,
    po.total_ht,
    coalesce(r.quantity_received, 0)                                    as quantity_received,
    round(coalesce(r.quantity_received, 0) * 100.0
          / nullIf(po.quantity_ordered, 0), 1)                          as receipt_rate_pct,
    r.first_received_at,
    r.last_received_at,
    if(r.first_received_at is not null and po.expected_at is not null,
       dateDiff('day', po.expected_at, r.first_received_at),
       null)                                                             as delivery_delay_days,
    if(r.first_received_at is not null and po.expected_at is not null,
       r.first_received_at <= po.expected_at,
       null)                                                             as is_on_time,
    coalesce(i.nb_invoices, 0)                                          as nb_invoices,
    coalesce(i.invoiced_ht, 0)                                          as invoiced_ht,
    coalesce(i.nb_invoices_paid, 0)                                     as nb_invoices_paid,
    coalesce(i.nb_invoices_overdue, 0)                                  as nb_invoices_overdue,
    multiIf(
        po.status = 'cancelled',                                        'cancelled',
        r.first_received_at is not null
            and coalesce(r.quantity_received, 0) >= po.quantity_ordered,'delivered',
        r.first_received_at is not null,                                'partial',
        po.expected_at is not null
            and today() > toDate(po.expected_at),                       'late',
        'pending'
    )                                                                   as delivery_status
from po_summary as po
left join receipt_summary as r
    on r.purchase_order_id = po.id_purchase_order
left join invoice_summary as i
    on i.purchase_order_id = po.id_purchase_order
