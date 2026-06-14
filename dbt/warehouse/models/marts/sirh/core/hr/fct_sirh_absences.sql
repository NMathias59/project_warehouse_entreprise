{{ config(materialized='table', engine='MergeTree()', order_by='(employee_id, start_date)', tags=['marts','sirh','fct']) }}
with absences as (
    select * from {{ ref('stg_sirh__absences') }}
),
absence_types as (
    select id_absence_type, label as absence_label, is_paid
    from {{ ref('stg_sirh__absence_types') }}
)
select
    a.id_absence,
    a.employee_id,
    a.absence_type_id,
    at.absence_label,
    at.is_paid,
    a.status,
    a.start_date,
    a.end_date,
    a.duration_days,
    a.reason,
    a.approved_by,
    a.approved_at,
    a.created_at,
    a.updated_at,
    a._etl_loaded_at
from absences as a
left join absence_types as at on at.id_absence_type = a.absence_type_id
