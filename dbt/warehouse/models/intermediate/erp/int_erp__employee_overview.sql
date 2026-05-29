{{ config(materialized='ephemeral', tags=['intermediate', 'erp']) }}

with employees as (
    select * from {{ ref('stg_erp__employees') }}
),
contracts as (
    select * from {{ ref('stg_erp__employee_contracts') }}
),
positions as (
    select * from {{ ref('stg_erp__positions') }}
),
departments as (
    select * from {{ ref('stg_erp__departments') }}
)

select
    e.id_employee,
    e.first_name,
    e.last_name,
    e.email,
    e.hired_at,
    e.left_at,
    e.is_active,
    p.title as position_title,
    d.name as department_name,
    c.type as contract_type,
    c.salary,
    c.currency,
    c.starts_at as contract_start,
    c.ends_at as contract_end,
    c.is_active as contract_active
from employees e
left join contracts c on e.id_employee = c.employee_id and c.is_active = true
left join positions p on e.position_id = p.id_position
left join departments d on e.department_id = d.id_department

