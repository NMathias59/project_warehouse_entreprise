{{ config(materialized='ephemeral', tags=['intermediate', 'erp']) }}

with employees as (
    select * from {{ ref('stg_erp__employees') }}
),
contracts_stats as (
    select * from {{ ref('int_erp__employee_contracts_stats') }}
)

select
    e.id_employee,
    e.first_name,
    e.last_name,
    e.email,
    cs.max_salary,
    cs.min_salary,
    cs.avg_salary,
    cs.nb_contracts
from employees e
left join contracts_stats cs on e.id_employee = cs.employee_id

