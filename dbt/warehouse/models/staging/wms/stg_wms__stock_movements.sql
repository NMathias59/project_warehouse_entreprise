{{ config(tags=['staging', 'wms']) }}

with source as (

    select * from {{ source('wms', 'stock_movements') }}
    where id is not null

),

deduped as (

    select
        id,
        argMax(reference,           _airbyte_extracted_at) as reference,
        argMax(movement_type,       _airbyte_extracted_at) as movement_type,
        argMax(product_id,          _airbyte_extracted_at) as product_id,
        argMax(location_id,         _airbyte_extracted_at) as location_id,
        argMax(warehouse_id,        _airbyte_extracted_at) as warehouse_id,
        argMax(source_document_id,  _airbyte_extracted_at) as source_document_id,
        argMax(quantity,            _airbyte_extracted_at) as quantity,
        argMax(unit_cost,           _airbyte_extracted_at) as unit_cost,
        argMax(moved_at,            _airbyte_extracted_at) as moved_at,
        argMax(created_by,          _airbyte_extracted_at) as created_by,
        argMax(created_at,          _airbyte_extracted_at) as created_at,
        max(_airbyte_extracted_at)                         as latest_extracted_at
    from source
    group by id

)

select
    cast(id                                    as varchar)       as id_stock_movement,
    cast(coalesce(reference, '')               as varchar)       as reference,
    cast(coalesce(movement_type, '')           as varchar)       as movement_type,
    cast(coalesce(product_id, '')              as varchar)       as product_id,
    cast(coalesce(location_id, '')             as varchar)       as location_id,
    cast(coalesce(warehouse_id, '')            as varchar)       as warehouse_id,
    cast(coalesce(source_document_id, '')      as varchar)       as source_document_id,
    cast(coalesce(quantity, 0)                 as decimal(18,2)) as quantity,
    cast(coalesce(unit_cost, 0)                as decimal(18,2)) as unit_cost,
    cast(moved_at                              as timestamp)     as moved_at,
    cast(coalesce(created_by, '')              as varchar)       as created_by,
    cast(created_at                            as timestamp)     as created_at,
    cast(latest_extracted_at                   as timestamp)     as _etl_loaded_at
from deduped
