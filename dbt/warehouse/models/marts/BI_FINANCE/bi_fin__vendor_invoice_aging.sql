{{ config(
    materialized='table',
    engine='MergeTree()',
    order_by='(issued_at, id_vendor_invoice)',
    tags=['bi', 'finance']
) }}

select
    vi.id_vendor_invoice,
    vi.reference,
    vi.status,
    vi.currency,
    vi.total_ht,
    vi.total_ttc,
    vi.supplier_id,
    s.supplier_name,
    vi.issued_at,
    vi.due_at,
    vi.paid_at,
    vi.purchase_order_id,
    dateDiff('day', vi.issued_at, vi.due_at)                           as payment_terms_days,
    if(vi.paid_at is not null,
       dateDiff('day', vi.due_at, toDate(vi.paid_at)),
       if(today() > vi.due_at, dateDiff('day', vi.due_at, today()), 0)) as days_overdue,
    if(vi.paid_at is not null, 1, 0)                                    as is_paid,
    if(vi.paid_at is null and today() > vi.due_at, 1, 0)               as is_past_due,
    multiIf(
        vi.paid_at is not null,                                 'paid',
        today() <= vi.due_at,                                   'current',
        dateDiff('day', vi.due_at, today()) <= 30,              'overdue_0_30d',
        dateDiff('day', vi.due_at, today()) <= 60,              'overdue_31_60d',
        dateDiff('day', vi.due_at, today()) <= 90,              'overdue_61_90d',
        'overdue_90d_plus'
    )                                                                   as aging_bucket
from {{ ref('stg_erp__vendor_invoices') }} as vi
left join {{ ref('dim_suppliers') }} as s
    on s.id_supplier = vi.supplier_id
