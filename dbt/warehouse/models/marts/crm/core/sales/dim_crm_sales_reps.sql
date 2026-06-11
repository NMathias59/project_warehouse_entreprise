{{ config(
    materialized='table',
    engine='MergeTree()',
    order_by='(id_sales_rep)',
    tags=['marts', 'crm', 'dim']
) }}

select
    sr.id_sales_rep,
    sr.code,
    sr.first_name,
    sr.last_name,
    concat(sr.first_name, ' ', sr.last_name)   as full_name,
    sr.email,
    sr.territory,
    sr.is_active,
    sr.created_at,
    s.nb_activities,
    s.nb_calls,
    s.nb_meetings,
    s.nb_emails,
    s.nb_opportunities,
    s.nb_opp_won,
    s.nb_opp_lost,
    s.win_rate_pct,
    s.revenue_won,
    s.pipeline_amount,
    s.nb_tasks,
    s.nb_tasks_done
from {{ ref('stg_crm__sales_reps') }} as sr
left join {{ ref('int_crm__sales_rep_stats') }} as s
    on s.id_sales_rep = sr.id_sales_rep
