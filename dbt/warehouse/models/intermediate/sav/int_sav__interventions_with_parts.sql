{{ config(materialized='ephemeral', tags=['intermediate', 'sav']) }}

with interventions as (
    select * from {{ ref('stg_sav__interventions') }}
),

spare_parts_used as (
    select * from {{ ref('stg_sav__spare_parts_used') }}
),

technicians as (
    select * from {{ ref('stg_sav__technicians') }}
)

select
    i.id_intervention,
    i.reference,
    i.status,
    i.intervention_type,
    i.ticket_id,
    i.technician_id,
    tech.first_name                                             as technician_first_name,
    tech.last_name                                              as technician_last_name,
    i.customer_id,
    i.product_id,
    i.diagnostic,
    i.resolution,
    i.scheduled_at,
    i.started_at,
    i.completed_at,
    i.duration_minutes,
    i.travel_km,
    count(spu.id_spare_part_used)                              as nb_parts_used,
    sum(spu.quantity * spu.unit_cost)                          as total_parts_cost,
    countIf(spu.is_under_warranty)                             as nb_warranty_parts
from interventions as i
left join spare_parts_used as spu
    on spu.intervention_id = i.id_intervention
left join technicians as tech
    on tech.id_technician = i.technician_id
group by
    i.id_intervention,
    i.reference,
    i.status,
    i.intervention_type,
    i.ticket_id,
    i.technician_id,
    tech.first_name,
    tech.last_name,
    i.customer_id,
    i.product_id,
    i.diagnostic,
    i.resolution,
    i.scheduled_at,
    i.started_at,
    i.completed_at,
    i.duration_minutes,
    i.travel_km
