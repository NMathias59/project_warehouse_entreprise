{{ config(tags=['staging', 'procurement']) }}

select
    cast('' as varchar)              as id_purchase_order_line,
    cast('' as varchar)              as purchase_order_id,
    cast('' as varchar)              as product_id,
    cast('' as varchar)              as description,
    cast(0 as decimal(18,2))         as quantity_ordered,
    cast(0 as decimal(18,2))         as quantity_received,
    cast(0 as decimal(18,2))         as unit_price,
    cast('' as varchar)              as unit_of_measure,
    cast(null as Nullable(DateTime64(3))) as expected_delivery_at,
    cast(null as Nullable(DateTime64(3))) as created_at,
    cast(null as Nullable(DateTime64(3))) as updated_at,
    cast(now() as timestamp)         as _etl_loaded_at
from {{ source('procurement', 'purchase_order_lines') }}
where 1 = 0
