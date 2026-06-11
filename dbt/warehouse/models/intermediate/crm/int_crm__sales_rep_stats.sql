{{ config(materialized='ephemeral', tags=['intermediate', 'crm']) }}

select
    sr.id_sales_rep,
    count(distinct act.id_activity)                                         as nb_activities,
    countIf(act.activity_type = 'call')                                     as nb_calls,
    countIf(act.activity_type = 'meeting')                                  as nb_meetings,
    countIf(act.activity_type = 'email')                                    as nb_emails,
    count(distinct opp.id_opportunity)                                      as nb_opportunities,
    countIf(opp.status = 'won')                                             as nb_opp_won,
    countIf(opp.status = 'lost')                                            as nb_opp_lost,
    round(
        countIf(opp.status = 'won') * 100.0
        / nullIf(countIf(opp.status in ('won', 'lost')), 0),
        1
    )                                                                       as win_rate_pct,
    sum(if(opp.status = 'won', opp.amount_estimated, 0))                    as revenue_won,
    sum(if(opp.status not in ('won', 'lost'), opp.amount_estimated, 0))     as pipeline_amount,
    count(distinct t.id_task)                                               as nb_tasks,
    countIf(t.status = 'done')                                              as nb_tasks_done
from {{ ref('stg_crm__sales_reps') }} as sr
left join {{ ref('stg_crm__activities') }} as act
    on act.owner_id = sr.id_sales_rep
left join {{ ref('stg_crm__opportunities') }} as opp
    on opp.owner_id = sr.id_sales_rep
left join {{ ref('stg_crm__tasks') }} as t
    on t.owner_id = sr.id_sales_rep
group by sr.id_sales_rep
