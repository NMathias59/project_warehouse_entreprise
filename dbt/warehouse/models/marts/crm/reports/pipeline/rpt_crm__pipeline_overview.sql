{{ config(
    materialized='table',
    engine='MergeTree()',
    order_by='(stage, id_opportunity)',
    tags=['reports', 'crm', 'pipeline']
) }}

select
    o.id_opportunity,
    o.title,
    o.stage,
    o.status,
    o.origin,
    o.probability,
    o.amount_estimated,
    o.expected_close_at,
    o.age_days,
    o.nb_stage_changes,
    o.days_in_current_stage,
    o.first_stage_change_at,
    o.last_stage_change_at,
    o.created_at,
    o.updated_at,
    a.name                                          as account_name,
    a.account_type,
    a.segment,
    a.country_code,
    a.lifetime_value                                as account_lifetime_value,
    concat(sr.first_name, ' ', sr.last_name)        as sales_rep_name,
    sr.territory,
    sr.win_rate_pct                                 as sales_rep_win_rate_pct,
    count(act.id_activity)                          as nb_activities,
    countIf(act.activity_type = 'call')             as nb_calls,
    countIf(act.activity_type = 'meeting')          as nb_meetings,
    countIf(act.activity_type = 'email')            as nb_emails,
    max(act.occurred_at)                            as last_activity_at
from {{ ref('fct_crm_opportunities') }} as o
left join {{ ref('dim_crm_accounts') }} as a
    on a.id_account = o.account_id
left join {{ ref('dim_crm_sales_reps') }} as sr
    on sr.id_sales_rep = o.owner_id
left join {{ ref('fct_crm_activities') }} as act
    on act.opportunity_id = o.id_opportunity
group by
    o.id_opportunity,
    o.title,
    o.stage,
    o.status,
    o.origin,
    o.probability,
    o.amount_estimated,
    o.expected_close_at,
    o.age_days,
    o.nb_stage_changes,
    o.days_in_current_stage,
    o.first_stage_change_at,
    o.last_stage_change_at,
    o.created_at,
    o.updated_at,
    a.name,
    a.account_type,
    a.segment,
    a.country_code,
    a.lifetime_value,
    sr.first_name,
    sr.last_name,
    sr.territory,
    sr.win_rate_pct
