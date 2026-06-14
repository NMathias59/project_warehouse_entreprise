{{ config(materialized='ephemeral', tags=['intermediate', 'sav']) }}

with customer_satisfaction as (
    select * from {{ ref('stg_sav__customer_satisfaction') }}
)

select
    survey_type,
    count(id_satisfaction)                                                              as nb_responses,
    avg(score)                                                                          as avg_score,
    min(score)                                                                          as min_score,
    max(score)                                                                          as max_score,
    countIf(score >= 9)                                                                 as nb_promoters,
    countIf(score <= 6)                                                                 as nb_detractors,
    ((countIf(score >= 9) - countIf(score <= 6)) / nullIf(count(id_satisfaction), 0))
        * 100                                                                           as nps_score
from customer_satisfaction
group by
    survey_type
