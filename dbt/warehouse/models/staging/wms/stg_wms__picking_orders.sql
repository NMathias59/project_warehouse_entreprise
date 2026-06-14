{{ config(tags=['staging', 'wms']) }}

with source as (

    select * from {{ source('wms', 'picking_orders') }}
    where id is not null

),

deduped as (

    select
        id,
        argMax(reference,     _airbyte_extracted_at) as reference,
        argMax(status,        _airbyte_extracted_at) as status,
        argMax(shipment_id,   _airbyte_extracted_at) as shipment_id,
        argMax(warehouse_id,  _airbyte_extracted_at) as warehouse_id,
        argMax(assigned_to,   _airbyte_extracted_at) as assigned_to,
        argMax(started_at,    _airbyte_extracted_at) as started_at,
        argMax(completed_at,  _airbyte_extracted_at) as completed_at,
        argMax(created_at,    _airbyte_extracted_at) as created_at,
        argMax(updated_at,    _airbyte_extracted_at) as updated_at,
        max(_airbyte_extracted_at)                   as latest_extracted_at
    from source
    group by id

)

select
    cast(id                                as varchar)   as id_picking_order,
    cast(coalesce(reference, '')           as varchar)   as reference,
    cast(coalesce(status, '')              as varchar)   as status,
    cast(coalesce(shipment_id, '')         as varchar)   as shipment_id,
    cast(coalesce(warehouse_id, '')        as varchar)   as warehouse_id,
    cast(coalesce(assigned_to, '')         as varchar)   as assigned_to,
    toDateTimeOrNull(toString(started_at))               as started_at,
    toDateTimeOrNull(toString(completed_at))             as completed_at,
    cast(created_at                        as timestamp) as created_at,
    toDateTimeOrNull(toString(updated_at))               as updated_at,
    cast(latest_extracted_at               as timestamp) as _etl_loaded_at
from deduped
