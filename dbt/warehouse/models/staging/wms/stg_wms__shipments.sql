{{ config(tags=['staging', 'wms']) }}

with base as (

    select * from {{ ref('base_wms__shipments') }}

)

select
    cast(id                                          as varchar)   as id_shipment,
    cast(coalesce(transfer_number,  '')              as varchar)   as reference,
    cast(coalesce(status,           '')              as varchar)   as status,
    cast(''                                          as varchar)   as order_id,
    cast(''                                          as varchar)   as carrier_id,
    cast(''                                          as varchar)   as warehouse_id,
    cast(''                                          as varchar)   as tracking_number,
    cast(null as Nullable(DateTime64(3)))                          as shipped_at,
    toDateTimeOrNull(toString(completed_at))                       as delivered_at,
    cast(created_at                                  as timestamp) as created_at,
    cast(null as Nullable(DateTime64(3)))                          as updated_at,
    cast(latest_extracted_at                as timestamp) as _etl_loaded_at
from base
