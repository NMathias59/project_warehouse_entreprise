{{ config(tags=['staging', 'wms']) }}

select
    cast(id                                                                           as varchar)       as id_inventory_adjustment,
    cast(coalesce(argMax(session_id,    _airbyte_extracted_at), '')                   as varchar)       as reference,
    cast('cycle_count'                                                                as varchar)       as adjustment_type,
    cast(coalesce(argMax(product_sku,   _airbyte_extracted_at), '')                   as varchar)       as product_id,
    cast(coalesce(argMax(location_id,   _airbyte_extracted_at), '')                   as varchar)       as location_id,
    cast(''                                                                           as varchar)       as warehouse_id,
    cast(coalesce(argMax(qty_system,    _airbyte_extracted_at), 0)                    as decimal(18,2)) as quantity_before,
    cast(coalesce(argMax(qty_counted,   _airbyte_extracted_at), 0)                    as decimal(18,2)) as quantity_after,
    cast(coalesce(argMax(variance,      _airbyte_extracted_at), 0)                    as decimal(18,2)) as delta_quantity,
    cast(''                                                                           as varchar)       as reason,
    cast(''                                                                           as varchar)       as adjusted_by,
    toDateTimeOrNull(toString(argMax(counted_at, _airbyte_extracted_at)))                               as adjusted_at,
    cast(max(_airbyte_extracted_at)                                                   as timestamp)     as created_at,
    cast(max(_airbyte_extracted_at)                                                   as timestamp)     as _etl_loaded_at
from {{ source('wms', 'inventory_adjustments') }}
where id is not null
group by id
