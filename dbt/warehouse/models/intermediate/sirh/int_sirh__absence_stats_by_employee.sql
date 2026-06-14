{{ config(materialized='ephemeral', tags=['intermediate', 'sirh']) }}

with absences as (
    select * from {{ ref('stg_sirh__absences') }}
),

absence_types as (
    select * from {{ ref('stg_sirh__absence_types') }}
)

select
    a.employee_id,
    count(a.id_absence)                                         as nb_absences_total,
    countIf(a.status = 'approved')                              as nb_absences_approved,
    countIf(a.status = 'requested')                             as nb_absences_pending,
    sumIf(a.duration_days, a.status = 'approved')               as total_days_approved,
    countIf(at.is_paid)                                         as nb_paid_absences,
    countIf(not at.is_paid)                                     as nb_unpaid_absences,
    max(a.start_date)                                           as last_absence_start_date
from absences as a
left join absence_types as at
    on at.id_absence_type = a.absence_type_id
group by
    a.employee_id
