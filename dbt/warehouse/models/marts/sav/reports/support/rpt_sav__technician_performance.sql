{{ config(materialized='table', engine='MergeTree()', order_by='(id_technician)', tags=['reports','sav','support']) }}
with interventions as (
    select
        id_intervention, technician_id, status, duration_minutes,
        nb_parts_used, total_parts_cost
    from {{ ref('fct_sav_interventions') }}
),
technicians as (
    select id_technician, code, first_name, last_name, specialization, is_active
    from {{ ref('dim_sav_technicians') }}
),
final as (
    select
        tech.id_technician,
        tech.code,
        tech.first_name,
        tech.last_name,
        tech.specialization,
        tech.is_active,
        count(i.id_intervention)                                as nb_interventions,
        countIf(i.status = 'completed')                         as nb_completed,
        countIf(i.status = 'cancelled')                         as nb_cancelled,
        avg(i.duration_minutes)                                 as avg_duration_minutes,
        sum(i.total_parts_cost)                                 as total_parts_cost,
        avg(i.nb_parts_used)                                    as avg_parts_per_intervention
    from technicians as tech
    left join interventions as i on i.technician_id = tech.id_technician
    group by
        tech.id_technician, tech.code, tech.first_name, tech.last_name,
        tech.specialization, tech.is_active
)
select * from final
