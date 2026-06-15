{{ config(tags=['staging', 'sirh']) }}

select
    cast('' as varchar)              as id_contract,
    cast('' as varchar)              as employee_id,
    cast('' as varchar)              as contract_type,
    cast('' as varchar)              as status,
    cast(null as Nullable(Date32))   as start_date,
    cast(null as Nullable(Date32))   as end_date,
    cast(0 as decimal(18,2))         as gross_salary,
    cast(0 as decimal(18,2))         as working_hours_per_week,
    cast(null as Nullable(DateTime64(3))) as created_at,
    cast(null as Nullable(DateTime64(3))) as updated_at,
    cast(now() as timestamp)         as _etl_loaded_at
from {{ source('sirh', 'contracts') }}
where 1 = 0
