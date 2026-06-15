{{ config(
    materialized='table',
    engine='MergeTree()',
    order_by='(id_sales_rep)',
    tags=['bi', 'commercial']
) }}

select
    sr.id_sales_rep,
    sr.full_name                                                            as sales_rep_name,
    sr.code,
    sr.email,
    sr.territory,
    sr.is_active,
    sr.nb_opportunities,
    sr.nb_opp_won,
    sr.nb_opp_lost,
    sr.win_rate_pct,
    sr.revenue_won,
    sr.pipeline_amount,
    sr.nb_activities,
    sr.nb_calls,
    sr.nb_meetings,
    sr.nb_emails,
    sr.nb_tasks,
    sr.nb_tasks_done,
    round(sr.nb_tasks_done * 100.0 / nullIf(sr.nb_tasks, 0), 1)            as task_completion_rate_pct,
    round(sr.revenue_won / nullIf(sr.nb_opp_won, 0), 2)                    as avg_deal_size,
    countIf(o.status not in ('won', 'lost'))                                as nb_active_opps,
    round(sum(if(o.status not in ('won', 'lost'),
               o.amount_estimated * o.probability / 100.0, 0)), 2)         as weighted_pipeline,
    countIf(o.status not in ('won', 'lost')
            and o.expected_close_at is not null
            and toDate(o.expected_close_at) <= today() + interval 30 day)  as nb_opps_closing_30d,
    round(avg(if(o.status = 'won', toFloat64(o.age_days), null)), 1)        as avg_days_to_close_won
from {{ ref('dim_crm_sales_reps') }} as sr
left join {{ ref('fct_crm_opportunities') }} as o
    on o.owner_id = sr.id_sales_rep
group by
    sr.id_sales_rep,
    sr.full_name,
    sr.code,
    sr.email,
    sr.territory,
    sr.is_active,
    sr.nb_opportunities,
    sr.nb_opp_won,
    sr.nb_opp_lost,
    sr.win_rate_pct,
    sr.revenue_won,
    sr.pipeline_amount,
    sr.nb_activities,
    sr.nb_calls,
    sr.nb_meetings,
    sr.nb_emails,
    sr.nb_tasks,
    sr.nb_tasks_done
