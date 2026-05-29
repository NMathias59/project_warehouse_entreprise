{{ config(materialized='ephemeral', tags=['intermediate', 'erp']) }}

with contracts as (
    select * from {{ ref('stg_erp__employee_contracts') }}
)

select
    employee_id,
    max(salary) as max_salary,
    min(salary) as min_salary,
    avg(salary) as avg_salary,
    count(*) as nb_contracts
from contracts
where salary is not null
  and is_active = true
  and starts_at <= today()
  and (ends_at is null or ends_at >= today())
group by employee_id

