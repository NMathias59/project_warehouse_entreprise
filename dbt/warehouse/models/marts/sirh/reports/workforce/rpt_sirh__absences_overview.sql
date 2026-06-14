{{ config(materialized='table', engine='MergeTree()', order_by='(start_date, employee_id)', tags=['reports','sirh','workforce']) }}
with absences as (
    select
        id_absence, employee_id, absence_label, is_paid,
        status, start_date, end_date, duration_days, approved_by
    from {{ ref('fct_sirh_absences') }}
),
employees as (
    select
        id_employee, employee_number, first_name, last_name,
        department_id, department_name
    from {{ ref('dim_sirh_employees') }}
),
final as (
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
    from absences as a
    left join employees as e on e.id_employee = a.employee_id
)
select * from final
