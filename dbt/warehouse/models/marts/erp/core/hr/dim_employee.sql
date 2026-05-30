{{
    config(
        materialized='table',
        tags=['core', 'erp', 'dim', 'hr']
    )
}}

select id_employee,
       is_active,
       position_title,
       department_name,
       contract_type,
       contract_active
from {{ ref('int_erp__employee_overview') }}