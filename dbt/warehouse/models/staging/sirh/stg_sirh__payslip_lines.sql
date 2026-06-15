{{ config(tags=['staging', 'sirh']) }}

select
    cast('' as varchar)              as id_payslip_line,
    cast('' as varchar)              as payslip_id,
    cast('' as varchar)              as line_type,
    cast('' as varchar)              as label,
    cast(0 as decimal(18,2))         as quantity,
    cast(0 as decimal(18,2))         as unit_rate,
    cast(0 as decimal(18,2))         as amount,
    cast(null as Nullable(DateTime64(3))) as created_at,
    cast(now() as timestamp)         as _etl_loaded_at
from {{ source('sirh', 'payslip_lines') }}
where 1 = 0
