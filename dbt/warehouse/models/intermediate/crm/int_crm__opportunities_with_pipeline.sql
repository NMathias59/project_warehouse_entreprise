{{ config(materialized='ephemeral', tags=['intermediate', 'crm']) }}

select
    o.id_opportunity,
    o.title,
    o.stage,
    o.status,
    o.origin,
    o.account_id,
    o.owner_id,
    o.source_order_id,
    o.probability,
    o.amount_estimated,
    o.expected_close_at,
    o.created_at,
    o.updated_at,
    dateDiff('day', o.created_at, now())                        as age_days,
    count(pe.id_pipeline_event)                                 as nb_stage_changes,
    min(pe.occurred_at)                                         as first_stage_change_at,
    max(pe.occurred_at)                                         as last_stage_change_at,
    dateDiff('day', max(pe.occurred_at), now())                 as days_in_current_stage
from {{ ref('stg_crm__opportunities') }} as o
left join {{ ref('stg_crm__pipeline_events') }} as pe
    on pe.opportunity_id = o.id_opportunity
group by
    o.id_opportunity,
    o.title,
    o.stage,
    o.status,
    o.origin,
    o.account_id,
    o.owner_id,
    o.source_order_id,
    o.probability,
    o.amount_estimated,
    o.expected_close_at,
    o.created_at,
    o.updated_at
