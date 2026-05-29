{{ config(tags=['staging', 'erp']) }}

select
    cast(id as varchar)             as id,
    cast(id as varchar)             as id_accounting_period,
    cast(label as varchar)          as label,
    cast(ends_at as timestamp)      as ends_at,
    cast(is_closed as boolean)      as is_closed,
    cast(starts_at as timestamp)    as starts_at,
    cast(created_at as timestamp)   as created_at,
    cast(fiscal_year_id as varchar) as fiscal_year_id
from {{ source('erp', 'accounting_periods') }}
where id is not null
