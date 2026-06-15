{{ config(tags=['staging', 'wms']) }}

select
    cast(id                                                                        as varchar)   as id_shipment,
    cast(coalesce(argMax(transfer_number,  _airbyte_extracted_at), '')             as varchar)   as reference,
    cast(coalesce(argMax(status,           _airbyte_extracted_at), '')             as varchar)   as status,
    cast(''                                                                        as varchar)   as order_id,
    cast(''                                                                        as varchar)   as carrier_id,
    cast(''                                                                        as varchar)   as warehouse_id,
    cast(''                                                                        as varchar)   as tracking_number,
    cast(null                                                                      as Nullable(DateTime64(3))) as shipped_at,
    toDateTimeOrNull(toString(argMax(completed_at, _airbyte_extracted_at)))                     as delivered_at,
    cast(argMax(created_at,                _airbyte_extracted_at)                  as timestamp) as created_at,
    cast(null                                                                      as Nullable(DateTime64(3))) as updated_at,
    cast(max(_airbyte_extracted_at)                                                as timestamp) as _etl_loaded_at
from {{ source('wms', 'shipments') }}
where id is not null
group by id
