{{ config(materialized='table', engine='MergeTree()', order_by='(submitted_at)', tags=['reports','plm','product']) }}
with cr as (
    select
        id_change_request, reference, title, change_type, priority, status,
        product_id, requested_by, approved_by,
        submitted_at, approved_at, implemented_at, created_at
    from {{ ref('fct_plm_change_requests') }}
),
products as (
    select id_product, code, name, lifecycle_status
    from {{ ref('dim_plm_products') }}
),
final as (
    select
        cr.id_change_request,
        cr.reference,
        cr.title,
        cr.change_type,
        cr.priority,
        cr.status,
        cr.product_id,
        p.code                                                  as product_code,
        p.name                                                  as product_name,
        p.lifecycle_status                                      as product_lifecycle_status,
        cr.requested_by,
        cr.approved_by,
        cr.submitted_at,
        cr.approved_at,
        cr.implemented_at,
        dateDiff('day', cr.submitted_at, cr.approved_at)        as approval_days,
        dateDiff('day', cr.approved_at, cr.implemented_at)      as implementation_days
    from cr
    left join products as p on p.id_product = cr.product_id
)
select * from final
