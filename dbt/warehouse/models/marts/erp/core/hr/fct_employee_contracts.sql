{{
    config(
        materialized='table',
        tags=['core', 'erp', 'fct', 'hr']
    )
}}

select
    employee_id,
    max_salary,
    min_salary,
    avg_salary,
    nb_contracts
from {{ ref('int_erp__employee_contracts_stats') }}