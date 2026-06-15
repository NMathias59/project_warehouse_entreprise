{{ config(tags=['staging', 'wms']) }}

select
    cast(id                                                                          as varchar)       as id_stock_movement,
    cast(''                                                                          as varchar)       as reference,
    cast('position'                                                                  as varchar)       as movement_type,
    cast(coalesce(argMax(product_sku,  _airbyte_extracted_at), '')                   as varchar)       as product_id,
    cast(coalesce(argMax(location_id,  _airbyte_extracted_at), '')                   as varchar)       as location_id,
    cast(''                                                                          as varchar)       as warehouse_id,
    cast(''                                                                          as varchar)       as source_document_id,
    cast(coalesce(argMax(qty_on_hand,  _airbyte_extracted_at), 0)                    as decimal(18,2)) as quantity,
    cast(0                                                                           as decimal(18,2)) as unit_cost,
    toDateTimeOrNull(toString(argMax(updated_at, _airbyte_extracted_at)))                              as moved_at,
    cast(''                                                                          as varchar)       as created_by,
    cast(max(_airbyte_extracted_at)                                                  as timestamp)     as created_at,
    cast(max(_airbyte_extracted_at)                                                  as timestamp)     as _etl_loaded_at
from {{ source('wms', 'stock_movements') }}
where id is not null
group by id
