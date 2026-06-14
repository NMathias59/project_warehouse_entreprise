{{ config(materialized='ephemeral', tags=['intermediate', 'wms']) }}

with shipments as (
    select * from {{ ref('stg_wms__shipments') }}
),

shipment_lines as (
    select * from {{ ref('stg_wms__shipment_lines') }}
)

select
    sl.id_shipment_line,
    s.id_shipment,
    s.reference,
    s.status,
    s.order_id,
    s.carrier_id,
    s.warehouse_id,
    s.tracking_number,
    s.shipped_at,
    s.delivered_at,
    sl.product_id,
    sl.location_id,
    sl.quantity
from shipments as s
left join shipment_lines as sl
    on sl.shipment_id = s.id_shipment
