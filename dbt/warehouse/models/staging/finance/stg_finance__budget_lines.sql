{{ config(tags=['staging', 'finance']) }}

select
    cast('' as varchar)                    as id_budget_line,
    cast('' as varchar)                    as budget_id,
    cast('' as varchar)                    as account_id,
    cast('' as varchar)                    as cost_center_id,
    0                                      as period_number,
    cast(0 as decimal(18,2))               as amount,
    cast('' as varchar)                    as notes,
    cast(null as Nullable(DateTime64(3))) as created_at,
    cast(null as Nullable(DateTime64(3))) as updated_at,
    cast(now() as timestamp)               as _etl_loaded_at
from {{ source('finance', 'budget_lines') }}
where 1 = 0
