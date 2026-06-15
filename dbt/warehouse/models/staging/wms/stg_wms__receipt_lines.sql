{{ config(tags=['staging', 'wms']) }}

select
    cast(id                                                                        as varchar)       as id_receipt_line,
    cast(coalesce(argMax(receipt_id,      _airbyte_extracted_at), '')              as varchar)       as receipt_id,
    cast(coalesce(argMax(product_sku,     _airbyte_extracted_at), '')              as varchar)       as product_id,
    cast(coalesce(argMax(put_location_id, _airbyte_extracted_at), '')              as varchar)       as location_id,
    cast(coalesce(argMax(qty_expected,    _airbyte_extracted_at), 0)               as decimal(18,2)) as quantity_expected,
    cast(coalesce(argMax(qty_received,    _airbyte_extracted_at), 0)               as decimal(18,2)) as quantity_received,
    cast(0                                                                         as decimal(18,2)) as unit_cost,
    cast(coalesce(argMax(lot_number,      _airbyte_extracted_at), '')              as varchar)       as lot_number,
    cast(null                                                                      as Nullable(DateTime64(3))) as expiry_date,
    cast(argMax(created_at,               _airbyte_extracted_at)                   as timestamp)     as created_at,
    cast(max(_airbyte_extracted_at)                                                as timestamp)     as _etl_loaded_at
from {{ source('wms', 'receipt_lines') }}
where id is not null
group by id
