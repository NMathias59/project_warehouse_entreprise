{{ config(materialized='table', engine='MergeTree()', order_by='(start_date, employee_id)', settings={'allow_nullable_key': 1}, tags=['reports','sirh','workforce']) }}

select
    a.id_absence,
    a.employee_id,
    e.employee_number,
    e.first_name,
    e.last_name,
    e.department_id,
    e.department_name,
    a.absence_label,
    a.is_paid,
    a.status,
    a.start_date,
    a.end_date,
    a.duration_days,
    a.approved_by
from {{ ref('fct_sirh_absences') }} as a
left join {{ ref('dim_sirh_employees') }} as e
    on e.id_employee = a.employee_id
