{{ config(materialized='table', engine='MergeTree()', order_by='(department_name)', tags=['reports','sirh','workforce']) }}

select
    department_id,
    any(department_name)                                        as department_name,
    count(id_employee)                                          as nb_employees,
    countIf(employment_status = 'active')                       as nb_active,
    countIf(employment_status = 'on_leave')                     as nb_on_leave,
    countIf(employment_status = 'terminated')                   as nb_terminated,
    avg(gross_salary)                                           as avg_gross_salary,
    countIf(contract_type = 'cdi')                              as nb_cdi,
    countIf(contract_type = 'cdd')                              as nb_cdd,
    countIf(contract_type = 'intern')                           as nb_intern
from {{ ref('dim_sirh_employees') }}
group by department_id
