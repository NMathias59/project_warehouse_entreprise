{{ config(materialized='table', engine='MergeTree()', order_by='(lifecycle_status, id_product)', tags=['reports','plm','product']) }}
with products as (
    select
        id_product, code, name, product_family, lifecycle_status,
        launch_date, end_of_life_date, latest_version_number,
        nb_versions, nb_approved_versions, nb_change_requests, nb_cr_open
    from {{ ref('dim_plm_products') }}
),
versions as (
    select
        product_id,
        countIf(status = 'approved')    as nb_approved_v,
        countIf(status = 'draft')       as nb_draft_v,
        max(approved_at)                as last_approval_at
    from {{ ref('fct_plm_product_versions') }}
    group by product_id
),
final as (
    select
        p.id_product,
        p.code,
        p.name,
        p.product_family,
        p.lifecycle_status,
        p.launch_date,
        p.end_of_life_date,
        p.latest_version_number,
        p.nb_versions,
        p.nb_approved_versions,
        p.nb_change_requests,
        p.nb_cr_open,
        v.last_approval_at
    from products as p
    left join versions as v on v.product_id = p.id_product
)
select * from final
