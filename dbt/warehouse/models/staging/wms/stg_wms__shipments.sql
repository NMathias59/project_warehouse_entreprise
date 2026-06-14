{{ config(tags=['staging', 'wms']) }}

with source as (

    select * from {{ source('wms', 'shipments') }}
    where id is not null

),

deduped as (

    select
        id,
        argMax(reference,        _airbyte_extracted_at) as reference,
        argMax(status,           _airbyte_extracted_at) as status,
        argMax(order_id,         _airbyte_extracted_at) as order_id,
        argMax(carrier_id,       _airbyte_extracted_at) as carrier_id,
        argMax(warehouse_id,     _airbyte_extracted_at) as warehouse_id,
        argMax(tracking_number,  _airbyte_extracted_at) as tracking_number,
        argMax(shipped_at,       _airbyte_extracted_at) as shipped_at,
        argMax(delivered_at,     _airbyte_extracted_at) as delivered_at,
        argMax(created_at,       _airbyte_extracted_at) as created_at,
        argMax(updated_at,       _airbyte_extracted_at) as updated_at,
        max(_airbyte_extracted_at)                      as latest_extracted_at
    from source
    group by id

)

select
    cast(id                                  as varchar)   as id_shipment,
    cast(coalesce(reference, '')             as varchar)   as reference,
    cast(coalesce(status, '')                as varchar)   as status,
    cast(coalesce(order_id, '')              as varchar)   as order_id,
    cast(coalesce(carrier_id, '')            as varchar)   as carrier_id,
    cast(coalesce(warehouse_id, '')          as varchar)   as warehouse_id,
    cast(coalesce(tracking_number, '')       as varchar)   as tracking_number,
    toDateTimeOrNull(toString(shipped_at))                as shipped_at,
    toDateTimeOrNull(toString(delivered_at))              as delivered_at,
    cast(created_at                          as timestamp) as created_at,
    toDateTimeOrNull(toString(updated_at))                as updated_at,
    cast(latest_extracted_at                 as timestamp) as _etl_loaded_at
from deduped
