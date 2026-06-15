{{ config(tags=['staging', 'wms']) }}

with base as (

    select * from {{ ref('base_wms__receipt_lines') }}

)

select
    cast(id                                      as varchar)       as id_receipt_line,
    cast(coalesce(receipt_id,      '')           as varchar)       as receipt_id,
    cast(coalesce(product_sku,     '')           as varchar)       as product_id,
    cast(coalesce(put_location_id, '')           as varchar)       as location_id,
    cast(coalesce(qty_expected,    0)            as decimal(18,2)) as quantity_expected,
    cast(coalesce(qty_received,    0)            as decimal(18,2)) as quantity_received,
    cast(0                                       as decimal(18,2)) as unit_cost,
    cast(coalesce(lot_number,      '')           as varchar)       as lot_number,
    cast(null as Nullable(DateTime64(3)))                          as expiry_date,
    cast(created_at                              as timestamp)     as created_at,
    cast(latest_extracted_at                as timestamp)     as _etl_loaded_at
from base
