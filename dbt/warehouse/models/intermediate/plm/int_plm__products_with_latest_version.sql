{{ config(materialized='ephemeral', tags=['intermediate', 'plm']) }}

with products as (
    select * from {{ ref('stg_plm__products') }}
),

product_versions as (
    select * from {{ ref('stg_plm__product_versions') }}
)

select
    p.id_product,
    p.code,
    p.name,
    p.product_family,
    p.lifecycle_status,
    p.responsible_id,
    p.launch_date,
    p.end_of_life_date,
    argMax(pv.version_number, pv.approved_at)       as latest_version_number,
    argMax(pv.version_status, pv.approved_at)       as latest_version_status,
    max(pv.approved_at)                             as latest_version_approved_at,
    count(pv.id_product_version)                    as nb_versions,
    countIf(pv.version_status = 'approved')         as nb_approved_versions
from products as p
left join product_versions as pv
    on pv.product_id = p.id_product
group by
    p.id_product,
    p.code,
    p.name,
    p.product_family,
    p.lifecycle_status,
    p.responsible_id,
    p.launch_date,
    p.end_of_life_date
