{{ config(tags=['staging', 'procurement']) }}

select
    cast('' as varchar)              as id_rfq_line,
    cast('' as varchar)              as rfq_id,
    cast('' as varchar)              as product_id,
    cast('' as varchar)              as description,
    cast(0 as decimal(18,2))         as quantity,
    cast('' as varchar)              as unit_of_measure,
    cast(null as Nullable(DateTime64(3))) as created_at,
    cast(now() as timestamp)         as _etl_loaded_at
from {{ source('procurement', 'rfq_lines') }}
where 1 = 0
