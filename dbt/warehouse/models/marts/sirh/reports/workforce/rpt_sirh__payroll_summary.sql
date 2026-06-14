{{ config(materialized='table', engine='MergeTree()', order_by='(pay_period_year, pay_period_month)', tags=['reports','sirh','workforce']) }}
with payslips as (
    select
        employee_id, pay_period_year, pay_period_month,
        gross_salary, net_salary, employer_charges, employee_charges, net_to_pay
    from {{ ref('fct_sirh_payslips') }}
),
final as (
    select
        pay_period_year,
        pay_period_month,
        count(*)                        as nb_payslips,
        sum(gross_salary)               as total_gross,
        sum(net_salary)                 as total_net,
        sum(employer_charges)           as total_employer_charges,
        sum(employee_charges)           as total_employee_charges,
        sum(net_to_pay)                 as total_net_to_pay,
        avg(gross_salary)               as avg_gross_salary
    from payslips
    group by pay_period_year, pay_period_month
)
select * from final
