{{ config(tags=['staging', 'wms']) }}

select
    cast(id                                                                        as varchar)       as id_shipment_line,
    cast(coalesce(argMax(transfer_order_id, _airbyte_extracted_at), '')            as varchar)       as shipment_id,
    cast(coalesce(argMax(product_sku,       _airbyte_extracted_at), '')            as varchar)       as product_id,
    cast(coalesce(argMax(to_location_id,    _airbyte_extracted_at), '')            as varchar)       as location_id,
    cast(coalesce(argMax(qty,               _airbyte_extracted_at), 0)             as decimal(18,2)) as quantity,
    toDateTimeOrNull(toString(argMax(moved_at, _airbyte_extracted_at)))                              as picked_at,
    cast(max(_airbyte_extracted_at)                                                as timestamp)     as created_at,
    cast(max(_airbyte_extracted_at)                                                as timestamp)     as _etl_loaded_at
from {{ source('wms', 'shipment_lines') }}
where id is not null
group by id
