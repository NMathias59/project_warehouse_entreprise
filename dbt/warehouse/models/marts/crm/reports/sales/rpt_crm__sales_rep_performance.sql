{{ config(
    materialized='table',
    engine='MergeTree()',
    order_by='(id_sales_rep)',
    tags=['reports', 'crm', 'sales']
) }}

select
    sr.id_sales_rep,
    sr.full_name                                                        as sales_rep_name,
    sr.code,
    sr.email,
    sr.territory,
    sr.is_active,
    sr.nb_activities,
    sr.nb_calls,
    sr.nb_meetings,
    sr.nb_emails,
    sr.nb_opportunities,
    sr.nb_opp_won,
    sr.nb_opp_lost,
    sr.win_rate_pct,
    sr.revenue_won,
    sr.pipeline_amount,
    sr.nb_tasks,
    sr.nb_tasks_done,
    round(sr.nb_tasks_done * 100.0 / nullIf(sr.nb_tasks, 0), 1)        as task_completion_rate_pct,
    count(distinct a.id_account)                                        as nb_accounts,
    countIf(a.status = 'active')                                        as nb_active_accounts,
    countIf(a.status = 'prospect')                                      as nb_prospects,
    sum(a.lifetime_value)                                               as total_account_ltv,
    max(act.occurred_at)                                                as last_activity_at,
    countIf(act.occurred_at >= today() - interval 30 day)              as nb_activities_last_30d,
    countIf(act.activity_type = 'call'
            and act.occurred_at >= today() - interval 30 day)          as nb_calls_last_30d
from {{ ref('dim_crm_sales_reps') }} as sr
left join {{ ref('dim_crm_accounts') }} as a
    on a.owner_id = sr.id_sales_rep
left join {{ ref('fct_crm_activities') }} as act
    on act.owner_id = sr.id_sales_rep
group by
    sr.id_sales_rep,
    sr.full_name,
    sr.code,
    sr.email,
    sr.territory,
    sr.is_active,
    sr.nb_activities,
    sr.nb_calls,
    sr.nb_meetings,
    sr.nb_emails,
    sr.nb_opportunities,
    sr.nb_opp_won,
    sr.nb_opp_lost,
    sr.win_rate_pct,
    sr.revenue_won,
    sr.pipeline_amount,
    sr.nb_tasks,
    sr.nb_tasks_done
