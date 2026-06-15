{{ config(tags=['staging', 'finance']) }}

select
    cast('' as varchar)                    as id_payment_term,
    cast('' as varchar)                    as code,
    cast('' as varchar)                    as label,
    0                                      as days_due,
    0                                      as discount_days,
    cast(0 as decimal(18,2))               as discount_percent,
    cast(false as boolean)                 as is_active,
    cast(null as Nullable(DateTime64(3))) as created_at,
    cast(now() as timestamp)               as _etl_loaded_at
from {{ source('finance', 'payment_terms') }}
where 1 = 0
