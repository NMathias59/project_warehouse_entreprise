{{ config(
    materialized='table',
    engine='MergeTree()',
    order_by='(stage, id_opportunity)',
    tags=['bi', 'commercial']
) }}

select
    o.id_opportunity,
    o.title,
    o.stage,
    o.status,
    o.origin,
    o.probability,
    o.amount_estimated,
    round(o.amount_estimated * o.probability / 100.0, 2)           as weighted_amount,
    o.expected_close_at,
    o.age_days,
    o.nb_stage_changes,
    o.days_in_current_stage,
    o.first_stage_change_at,
    o.last_stage_change_at,
    o.created_at,
    o.updated_at,
    a.name                                                          as account_name,
    a.account_type,
    a.segment,
    a.country_code,
    a.lifetime_value                                                as account_lifetime_value,
    concat(sr.first_name, ' ', sr.last_name)                       as sales_rep_name,
    sr.territory,
    sr.win_rate_pct                                                 as sales_rep_win_rate_pct,
    count(act.id_activity)                                          as nb_activities,
    countIf(act.activity_type = 'call')                             as nb_calls,
    countIf(act.activity_type = 'meeting')                          as nb_meetings,
    countIf(act.activity_type = 'email')                            as nb_emails,
    max(act.occurred_at)                                            as last_activity_at,
    if(max(act.occurred_at) is not null,
       dateDiff('day', max(act.occurred_at), now()),
       null)                                                        as days_since_last_activity,
    multiIf(
        o.status in ('won', 'lost'),                                false,
        max(act.occurred_at) is null,                               true,
        dateDiff('day', max(act.occurred_at), now()) > 30,          true,
        false
    )                                                               as is_stalled,
    multiIf(
        o.status = 'won',                                           'won',
        o.status = 'lost',                                          'lost',
        o.probability >= 70,                                        'high_confidence',
        o.probability >= 40,                                        'medium_confidence',
        'low_confidence'
    )                                                               as confidence_label
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
