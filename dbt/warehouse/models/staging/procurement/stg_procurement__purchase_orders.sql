{{ config(tags=['staging', 'procurement']) }}

select
    cast('' as varchar)              as id_purchase_order,
    cast('' as varchar)              as reference,
    cast('' as varchar)              as supplier_id,
    cast('' as varchar)              as contract_id,
    cast('' as varchar)              as status,
    cast('' as varchar)              as buyer_id,
    cast('' as varchar)              as delivery_address,
    cast('' as varchar)              as currency,
    cast(0 as decimal(18,2))         as total_amount,
    cast(null as Nullable(DateTime64(3))) as expected_delivery_at,
    cast(null as Nullable(DateTime64(3))) as sent_at,
    cast(null as Nullable(DateTime64(3))) as created_at,
    cast(null as Nullable(DateTime64(3))) as updated_at,
    cast(now() as timestamp)         as _etl_loaded_at
from {{ source('procurement', 'purchase_orders') }}
where 1 = 0
