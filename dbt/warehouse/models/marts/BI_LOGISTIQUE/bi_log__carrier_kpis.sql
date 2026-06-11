{{ config(
    materialized='table',
    engine='MergeTree()',
    order_by='tuple()',
    tags=['bi', 'logistique']
) }}

select
    shipment_carrier_id,
    carrier_name,
    shipment_month,
    count(shipment_id)                                                  as total_shipments,
    countIf(is_delivered = 1)                                           as delivered_count,
    countIf(is_returned = 1)                                            as returned_count,
    round(countIf(is_delivered = 1) * 100.0
          / nullIf(count(shipment_id), 0), 2)                          as delivery_rate_pct,
    round(countIf(is_returned = 1) * 100.0
          / nullIf(count(shipment_id), 0), 2)                          as return_rate_pct,
    round(avg(transit_days), 1)                                         as avg_transit_days,
    round(avg(fulfillment_days), 1)                                     as avg_fulfillment_days,
    round(avg(total_delivery_days), 1)                                  as avg_total_delivery_days,
    min(transit_days)                                                   as min_transit_days,
    max(transit_days)                                                   as max_transit_days
from {{ ref('rpt_mkt__logistics_performance') }}
where carrier_name != ''
  and shipment_month is not null
group by shipment_carrier_id, carrier_name, shipment_month
