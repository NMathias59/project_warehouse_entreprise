{{ config(materialized='table', engine='MergeTree()', order_by='(id_product)', tags=['marts','plm','dim']) }}

select
    p.id_product                    as id_product,
    p.code                          as code,
    p.name                          as name,
    p.description                   as description,
    p.product_family                as product_family,
    p.lifecycle_status              as lifecycle_status,
    p.responsible_id                as responsible_id,
    p.launch_date                   as launch_date,
    p.end_of_life_date              as end_of_life_date,
    p.created_at                    as created_at,
    p.updated_at                    as updated_at,
    v.latest_version_number         as latest_version_number,
    v.latest_version_status         as latest_version_status,
    v.nb_versions                   as nb_versions,
    v.nb_approved_versions          as nb_approved_versions,
    cr.nb_change_requests           as nb_change_requests,
    cr.nb_open                      as nb_cr_open,
    cr.nb_high_priority             as nb_cr_high_priority
from {{ ref('stg_plm__products') }} as p
left join {{ ref('int_plm__products_with_latest_version') }} as v
    on v.id_product = p.id_product
left join {{ ref('int_plm__change_requests_by_product') }} as cr
    on cr.product_id = p.id_product
