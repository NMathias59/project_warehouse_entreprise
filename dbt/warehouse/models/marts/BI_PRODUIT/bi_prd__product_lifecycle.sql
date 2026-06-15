{{ config(
    materialized='table',
    engine='MergeTree()',
    order_by='(id_product)',
    tags=['bi', 'produit']
) }}

with bom_stats as (
    select
        pv.product_id,
        count(b.id_bom_line)            as nb_bom_components,
        countIf(b.is_critical)          as nb_critical_components,
        max(b.lead_time_days)           as max_component_lead_time_days
    from {{ ref('fct_plm_product_versions') }} as pv
    left join {{ ref('fct_plm_bom') }} as b
        on b.product_version_id = pv.id_product_version
    group by pv.product_id
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
    p.latest_version_number,
    p.latest_version_status,
    p.nb_versions,
    p.nb_approved_versions,
    p.nb_change_requests,
    p.nb_cr_open,
    p.nb_cr_high_priority,
    coalesce(b.nb_bom_components, 0)            as nb_bom_components,
    coalesce(b.nb_critical_components, 0)       as nb_critical_components,
    coalesce(b.max_component_lead_time_days, 0) as max_component_lead_time_days,
    if(p.end_of_life_date is not null,
       dateDiff('day', today(), p.end_of_life_date),
       null)                                    as days_to_eol,
    if(p.nb_cr_open > 0 or p.nb_cr_high_priority > 0, 1, 0)
                                                as has_pending_changes,
    if(p.end_of_life_date is not null
       and dateDiff('day', today(), p.end_of_life_date) <= 90
       and p.lifecycle_status != 'end_of_life',
       1, 0)                                    as is_approaching_eol,
    multiIf(
        p.lifecycle_status = 'active',          'active',
        p.lifecycle_status = 'in_development',  'development',
        p.lifecycle_status = 'end_of_life',     'eol',
        p.lifecycle_status = 'discontinued',    'discontinued',
        'unknown'
    )                                           as lifecycle_label
from {{ ref('dim_plm_products') }} as p
left join bom_stats as b
    on b.product_id = p.id_product
