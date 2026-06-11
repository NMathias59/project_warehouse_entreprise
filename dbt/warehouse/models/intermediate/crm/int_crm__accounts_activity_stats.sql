{{ config(materialized='ephemeral', tags=['intermediate', 'crm']) }}

select
    a.id_account,
    count(distinct act.id_activity)                                         as nb_activities,
    countIf(act.activity_type = 'call')                                     as nb_calls,
    countIf(act.activity_type = 'meeting')                                  as nb_meetings,
    countIf(act.activity_type = 'email')                                    as nb_emails,
    count(distinct opp.id_opportunity)                                      as nb_opportunities,
    countIf(opp.status = 'won')                                             as nb_opp_won,
    countIf(opp.status = 'lost')                                            as nb_opp_lost,
    sum(if(opp.status = 'won', opp.amount_estimated, 0))                    as revenue_won,
    sum(if(opp.status not in ('won', 'lost'), opp.amount_estimated, 0))     as pipeline_amount,
    max(act.occurred_at)                                                    as last_activity_at,
    count(distinct t.id_task)                                               as nb_tasks
from {{ ref('stg_crm__accounts') }} as a
left join {{ ref('stg_crm__activities') }} as act
    on act.account_id = a.id_account
left join {{ ref('stg_crm__opportunities') }} as opp
    on opp.account_id = a.id_account
left join {{ ref('stg_crm__tasks') }} as t
    on t.account_id = a.id_account
group by a.id_account
