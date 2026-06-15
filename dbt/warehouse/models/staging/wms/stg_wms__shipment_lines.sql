{{ config(tags=['staging', 'wms']) }}

with base as (

    select * from {{ ref('base_wms__shipment_lines') }}

)

select
    cast(id                                      as varchar)       as id_shipment_line,
    cast(coalesce(transfer_order_id, '')         as varchar)       as shipment_id,
    cast(coalesce(product_sku,       '')         as varchar)       as product_id,
    cast(coalesce(to_location_id,    '')         as varchar)       as location_id,
    cast(coalesce(qty,               0)          as decimal(18,2)) as quantity,
    toDateTimeOrNull(toString(moved_at))                           as picked_at,
    cast(latest_extracted_at                as timestamp)     as created_at,
    cast(latest_extracted_at                as timestamp)     as _etl_loaded_at
from base
