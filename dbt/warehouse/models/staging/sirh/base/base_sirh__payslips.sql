{{ config(materialized='view', tags=['staging', 'sirh']) }}

select
    id,
    argMax(employee_id,           _airbyte_extracted_at) as employee_id,
    argMax(pay_period_year,       _airbyte_extracted_at) as pay_period_year,
    argMax(pay_period_month,      _airbyte_extracted_at) as pay_period_month,
    argMax(gross_salary_eur,      _airbyte_extracted_at) as gross_salary,
    argMax(net_salary_eur,        _airbyte_extracted_at) as net_salary,
    argMax(employer_charges_eur,  _airbyte_extracted_at) as employer_charges,
    argMax(employee_charges_eur,  _airbyte_extracted_at) as employee_charges,
    argMax(payment_date,          _airbyte_extracted_at) as paid_at,
    max(_airbyte_extracted_at)                    as latest_extracted_at
from {{ source('sirh', 'payslips') }}
where id is not null
group by id
