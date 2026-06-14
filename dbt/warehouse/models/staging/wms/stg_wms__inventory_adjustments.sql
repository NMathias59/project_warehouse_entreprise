{{ config(tags=['staging', 'wms']) }}

with source as (

    select * from {{ source('wms', 'inventory_adjustments') }}
    where id is not null

),

deduped as (

    select
        id,
        argMax(reference,        _airbyte_extracted_at) as reference,
        argMax(adjustment_type,  _airbyte_extracted_at) as adjustment_type,
        argMax(product_id,       _airbyte_extracted_at) as product_id,
        argMax(location_id,      _airbyte_extracted_at) as location_id,
        argMax(warehouse_id,     _airbyte_extracted_at) as warehouse_id,
        argMax(quantity_before,  _airbyte_extracted_at) as quantity_before,
        argMax(quantity_after,   _airbyte_extracted_at) as quantity_after,
        argMax(delta_quantity,   _airbyte_extracted_at) as delta_quantity,
        argMax(reason,           _airbyte_extracted_at) as reason,
        argMax(adjusted_by,      _airbyte_extracted_at) as adjusted_by,
        argMax(adjusted_at,      _airbyte_extracted_at) as adjusted_at,
        argMax(created_at,       _airbyte_extracted_at) as created_at,
        max(_airbyte_extracted_at)                      as latest_extracted_at
    from source
    group by id

)

select
    cast(id                                  as varchar)       as id_inventory_adjustment,
    cast(coalesce(reference, '')             as varchar)       as reference,
    cast(coalesce(adjustment_type, '')       as varchar)       as adjustment_type,
    cast(coalesce(product_id, '')            as varchar)       as product_id,
    cast(coalesce(location_id, '')           as varchar)       as location_id,
    cast(coalesce(warehouse_id, '')          as varchar)       as warehouse_id,
    cast(coalesce(quantity_before, 0)        as decimal(18,2)) as quantity_before,
    cast(coalesce(quantity_after, 0)         as decimal(18,2)) as quantity_after,
    cast(coalesce(delta_quantity, 0)         as decimal(18,2)) as delta_quantity,
    cast(coalesce(reason, '')                as varchar)       as reason,
    cast(coalesce(adjusted_by, '')           as varchar)       as adjusted_by,
    cast(adjusted_at                         as timestamp)     as adjusted_at,
    cast(created_at                          as timestamp)     as created_at,
    cast(latest_extracted_at                 as timestamp)     as _etl_loaded_at
from deduped
