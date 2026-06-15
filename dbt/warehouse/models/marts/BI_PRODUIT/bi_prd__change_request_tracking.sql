{{ config(
    materialized='table',
    engine='MergeTree()',
    order_by='(id_change_request, submitted_at)',
    settings={'allow_nullable_key': 1},
    tags=['bi', 'produit']
) }}

select
    cr.id_change_request,
    cr.reference,
    cr.title,
    cr.description,
    cr.product_id,
    cr.change_type,
    cr.priority,
    cr.status,
    cr.requested_by,
    cr.approved_by,
    cr.submitted_at,
    cr.approved_at,
    cr.implemented_at,
    p.code                                                          as product_code,
    p.name                                                          as product_name,
    p.product_family,
    p.lifecycle_status                                              as product_lifecycle_status,
    if(cr.approved_at is not null and cr.submitted_at is not null,
       dateDiff('day', cr.submitted_at, cr.approved_at),
       null)                                                        as approval_lead_time_days,
    if(cr.implemented_at is not null and cr.approved_at is not null,
       dateDiff('day', cr.approved_at, cr.implemented_at),
       null)                                                        as implementation_lead_time_days,
    if(cr.implemented_at is not null and cr.submitted_at is not null,
       dateDiff('day', cr.submitted_at, cr.implemented_at),
       null)                                                        as total_cycle_days,
    multiIf(
        cr.status = 'implemented',                                  'completed',
        cr.status = 'rejected',                                     'rejected',
        cr.status = 'approved',                                     'awaiting_implementation',
        cr.status = 'under_review',                                 'in_review',
        cr.status = 'submitted',                                    'pending_review',
        'draft'
    )                                                               as tracking_status,
    if(cr.status in ('draft', 'submitted', 'under_review')
       and cr.submitted_at is not null
       and dateDiff('day', cr.submitted_at, now()) > 30,
       1, 0)                                                        as is_overdue
from {{ ref('fct_plm_change_requests') }} as cr
left join {{ ref('dim_plm_products') }} as p
    on p.id_product = cr.product_id
