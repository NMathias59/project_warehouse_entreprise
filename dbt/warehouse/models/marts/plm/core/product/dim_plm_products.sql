{{ config(materialized='table', engine='MergeTree()', order_by='(id_product)', tags=['marts','plm','dim']) }}
with products as (
    select
        id_product, code, name, description, product_family, lifecycle_status,
        responsible_id, launch_date, end_of_life_date, created_at, updated_at
    from {{ ref('stg_plm__products') }}
),
versions as (
    select
        id_product,
        latest_version_number,
        latest_version_status,
        nb_versions,
        nb_approved_versions
    from {{ ref('int_plm__products_with_latest_version') }}
),
cr_stats as (
    select
        product_id,
        nb_change_requests,
        nb_open        as nb_cr_open,
        nb_high_priority as nb_cr_high_priority
    from {{ ref('int_plm__change_requests_by_product') }}
)
select
    p.id_product,
    p.code,
    p.name,
    p.description,
    p.product_family,
    p.lifecycle_status,
    p.responsible_id,
    p.launch_date,
    p.end_of_life_date,
    p.created_at,
    p.updated_at,
    v.latest_version_number,
    v.latest_version_status,
    v.nb_versions,
    v.nb_approved_versions,
    cr.nb_change_requests,
    cr.nb_cr_open,
    cr.nb_cr_high_priority
from products as p
left join versions as v   on v.id_product  = p.id_product
left join cr_stats as cr  on cr.product_id = p.id_product
