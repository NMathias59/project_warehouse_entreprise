{{ config(tags=['staging', 'sirh']) }}

with source as (

    select * from {{ source('sirh', 'payslips') }}
    where id is not null

),

deduped as (

    select
        id,
        argMax(employee_id,        _airbyte_extracted_at) as employee_id,
        argMax(contract_id,        _airbyte_extracted_at) as contract_id,
        argMax(pay_period_year,    _airbyte_extracted_at) as pay_period_year,
        argMax(pay_period_month,   _airbyte_extracted_at) as pay_period_month,
        argMax(gross_salary,       _airbyte_extracted_at) as gross_salary,
        argMax(net_salary,         _airbyte_extracted_at) as net_salary,
        argMax(employer_charges,   _airbyte_extracted_at) as employer_charges,
        argMax(employee_charges,   _airbyte_extracted_at) as employee_charges,
        argMax(net_to_pay,         _airbyte_extracted_at) as net_to_pay,
        argMax(paid_at,            _airbyte_extracted_at) as paid_at,
        argMax(created_at,         _airbyte_extracted_at) as created_at,
        max(_airbyte_extracted_at)                        as latest_extracted_at
    from source
    group by id

)

select
    cast(id                                  as varchar)       as id_payslip,
    cast(coalesce(employee_id, '')           as varchar)       as employee_id,
    cast(coalesce(contract_id, '')           as varchar)       as contract_id,
    coalesce(pay_period_year, 0)                               as pay_period_year,
    coalesce(pay_period_month, 0)                              as pay_period_month,
    cast(coalesce(gross_salary, 0)           as decimal(18,2)) as gross_salary,
    cast(coalesce(net_salary, 0)             as decimal(18,2)) as net_salary,
    cast(coalesce(employer_charges, 0)       as decimal(18,2)) as employer_charges,
    cast(coalesce(employee_charges, 0)       as decimal(18,2)) as employee_charges,
    cast(coalesce(net_to_pay, 0)             as decimal(18,2)) as net_to_pay,
    toDateTimeOrNull(toString(paid_at))                        as paid_at,
    cast(created_at                          as timestamp)     as created_at,
    cast(latest_extracted_at                 as timestamp)     as _etl_loaded_at
from deduped
