{{ config(tags=['staging', 'wms']) }}

with source as (

    select * from {{ source('wms', 'picking_lines') }}
    where id is not null

),

deduped as (

    select
        id,
        argMax(picking_order_id,   _airbyte_extracted_at) as picking_order_id,
        argMax(product_id,         _airbyte_extracted_at) as product_id,
        argMax(location_id,        _airbyte_extracted_at) as location_id,
        argMax(quantity_requested, _airbyte_extracted_at) as quantity_requested,
        argMax(quantity_picked,    _airbyte_extracted_at) as quantity_picked,
        argMax(is_completed,       _airbyte_extracted_at) as is_completed,
        argMax(picked_at,          _airbyte_extracted_at) as picked_at,
        argMax(created_at,         _airbyte_extracted_at) as created_at,
        max(_airbyte_extracted_at)                        as latest_extracted_at
    from source
    group by id

)

select
    cast(id                                    as varchar)       as id_picking_line,
    cast(coalesce(picking_order_id, '')        as varchar)       as picking_order_id,
    cast(coalesce(product_id, '')              as varchar)       as product_id,
    cast(coalesce(location_id, '')             as varchar)       as location_id,
    cast(coalesce(quantity_requested, 0)       as decimal(18,2)) as quantity_requested,
    cast(coalesce(quantity_picked, 0)          as decimal(18,2)) as quantity_picked,
    cast(coalesce(is_completed, false)         as boolean)       as is_completed,
    toDateTimeOrNull(toString(picked_at))                        as picked_at,
    cast(created_at                            as timestamp)     as created_at,
    cast(latest_extracted_at                   as timestamp)     as _etl_loaded_at
from deduped
