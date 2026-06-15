{{ config(tags=['staging', 'wms']) }}

with base as (

    select * from {{ ref('base_wms__picking_orders') }}

)

select
    cast(id                                              as varchar)   as id_picking_order,
    cast(coalesce(pick_order_number,      '')            as varchar)   as reference,
    cast(coalesce(status,                 '')            as varchar)   as status,
    cast(coalesce(marketplace_order_ref,  '')            as varchar)   as shipment_id,
    cast(''                                              as varchar)   as warehouse_id,
    cast(coalesce(assigned_to_ref,        '')            as varchar)   as assigned_to,
    toDateTimeOrNull(toString(started_at))                             as started_at,
    toDateTimeOrNull(toString(completed_at))                           as completed_at,
    cast(created_at                                      as timestamp) as created_at,
    cast(null as Nullable(DateTime64(3)))                              as updated_at,
    cast(latest_extracted_at                as timestamp) as _etl_loaded_at
from base
