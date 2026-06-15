{{ config(tags=['staging', 'procurement']) }}

select
    cast('' as varchar)              as id_receipt,
    cast('' as varchar)              as reference,
    cast('' as varchar)              as purchase_order_id,
    cast('' as varchar)              as warehouse_id,
    cast('' as varchar)              as status,
    cast('' as varchar)              as received_by,
    cast(null as Nullable(DateTime64(3))) as received_at,
    cast(null as Nullable(DateTime64(3))) as created_at,
    cast(now() as timestamp)         as _etl_loaded_at
from {{ source('procurement', 'receipts') }}
where 1 = 0
