{{ config(materialized='table', tags=['mart','erp','core']) }}

select
    id_employee,
    first_name,
    last_name,
    email,
    hired_at,
    left_at,
    position_title,
    department_name,
    contract_type,
    salary,
    currency,
    contract_start,
    contract_end,
    contract_active
from {{ ref('int_erp__employee_overview') }}