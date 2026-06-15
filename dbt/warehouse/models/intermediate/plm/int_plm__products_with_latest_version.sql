{{ config(materialized='view', tags=['intermediate', 'plm']) }}

select
    p.id_product                                        as id_product,
    p.code                                              as code,
    p.name                                              as name,
    p.product_family                                    as product_family,
    p.lifecycle_status                                  as lifecycle_status,
    p.responsible_id                                    as responsible_id,
    p.launch_date                                       as launch_date,
    p.end_of_life_date                                  as end_of_life_date,
    argMax(pv.version_number, pv.approved_at)           as latest_version_number,
    argMax(pv.status, pv.approved_at)                   as latest_version_status,
    max(pv.approved_at)                                 as latest_version_approved_at,
    count(pv.id_product_version)                        as nb_versions,
    countIf(pv.status = 'approved')                     as nb_approved_versions
from {{ ref('stg_plm__products') }} as p
left join {{ ref('stg_plm__product_versions') }} as pv
    on pv.product_id = p.id_product
group by
    id_product,
    code,
    name,
    product_family,
    lifecycle_status,
    responsible_id,
    launch_date,
    end_of_life_date
