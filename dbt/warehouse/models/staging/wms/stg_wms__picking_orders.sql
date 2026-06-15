{{ config(tags=['staging', 'wms']) }}

select
    cast(id                                                                        as varchar)   as id_picking_order,
    cast(coalesce(argMax(pick_order_number,      _airbyte_extracted_at), '')       as varchar)   as reference,
    cast(coalesce(argMax(status,                 _airbyte_extracted_at), '')       as varchar)   as status,
    cast(coalesce(argMax(marketplace_order_ref,  _airbyte_extracted_at), '')       as varchar)   as shipment_id,
    cast(''                                                                        as varchar)   as warehouse_id,
    cast(coalesce(argMax(assigned_to_ref,        _airbyte_extracted_at), '')       as varchar)   as assigned_to,
    toDateTimeOrNull(toString(argMax(started_at,   _airbyte_extracted_at)))                     as started_at,
    toDateTimeOrNull(toString(argMax(completed_at, _airbyte_extracted_at)))                     as completed_at,
    cast(argMax(created_at,                        _airbyte_extracted_at)          as timestamp) as created_at,
    cast(null                                                                      as Nullable(DateTime64(3))) as updated_at,
    cast(max(_airbyte_extracted_at)                                                as timestamp) as _etl_loaded_at
from {{ source('wms', 'picking_orders') }}
where id is not null
group by id
