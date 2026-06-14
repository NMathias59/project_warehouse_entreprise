{{ config(materialized='ephemeral', tags=['intermediate', 'sirh']) }}

with employees as (
    select * from {{ ref('stg_sirh__employees') }}
),

contracts as (
    select * from {{ ref('stg_sirh__contracts') }}
),

positions as (
    select * from {{ ref('stg_sirh__positions') }}
),

departments as (
    select * from {{ ref('stg_sirh__departments') }}
)

select
    e.id_employee,
    e.employee_number,
    e.first_name,
    e.last_name,
    e.email,
    e.employment_status,
    e.hire_date,
    e.termination_date,
    e.position_id,
    any(pos.title)                                          as position_title,
    any(pos.job_family)                                     as position_job_family,
    e.department_id,
    any(dept.name)                                          as department_name,
    e.manager_id,
    argMax(c.contract_type, c.start_date)                   as contract_type,
    argMax(c.gross_salary, c.start_date)                    as gross_salary,
    argMax(c.working_hours_per_week, c.start_date)          as working_hours_per_week,
    argMax(c.start_date, c.start_date)                      as contract_start_date,
    count(c.id_contract)                                    as nb_contracts
from employees as e
left join contracts as c
    on c.employee_id = e.id_employee
left join positions as pos
    on pos.id_position = e.position_id
left join departments as dept
    on dept.id_department = e.department_id
group by
    e.id_employee,
    e.employee_number,
    e.first_name,
    e.last_name,
    e.email,
    e.employment_status,
    e.hire_date,
    e.termination_date,
    e.position_id,
    e.department_id,
    e.manager_id
