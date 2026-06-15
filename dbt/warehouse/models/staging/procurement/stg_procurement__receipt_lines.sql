{{ config(tags=['staging', 'procurement']) }}

select
    cast('' as varchar)              as id_receipt_line,
    cast('' as varchar)              as receipt_id,
    cast('' as varchar)              as purchase_order_line_id,
    cast('' as varchar)              as product_id,
    cast(0 as decimal(18,2))         as quantity_received,
    cast(0 as decimal(18,2))         as unit_cost,
    cast('' as varchar)              as lot_number,
    cast(null as Nullable(DateTime64(3))) as created_at,
    cast(now() as timestamp)         as _etl_loaded_at
from {{ source('procurement', 'receipt_lines') }}
where 1 = 0
