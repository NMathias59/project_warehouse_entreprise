{{ config(materialized='ephemeral', tags=['intermediate', 'sirh']) }}

with payslips as (
    select * from {{ ref('stg_sirh__payslips') }}
)

select
    pay_period_year,
    pay_period_month,
    count(id_payslip)                   as nb_payslips,
    sum(gross_salary)                   as total_gross,
    sum(net_salary)                     as total_net,
    sum(employer_charges)               as total_employer_charges,
    sum(employee_charges)               as total_employee_charges,
    sum(net_to_pay)                     as total_net_to_pay,
    avg(gross_salary)                   as avg_gross_salary
from payslips
group by
    pay_period_year,
    pay_period_month
