{{ config(tags=['staging', 'finance']) }}

select
    cast('' as varchar)                    as id_accounting_period,
    cast('' as varchar)                    as fiscal_year_id,
    0                                      as period_number,
    cast('' as varchar)                    as label,
    cast(null as Nullable(Date32))         as start_date,
    cast(null as Nullable(Date32))         as end_date,
    cast(false as boolean)                 as is_closed,
    cast(null as Nullable(DateTime64(3))) as closed_at,
    cast(null as Nullable(DateTime64(3))) as created_at,
    cast(now() as timestamp)               as _etl_loaded_at
from {{ source('finance', 'accounting_periods') }}
where 1 = 0
