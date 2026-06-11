{{ config(
    materialized='table',
    engine='MergeTree()',
    order_by='tuple()',
    tags=['reports', 'market_place', 'logistics']
) }}

with shipments_by_carrier as (

    select
        shipment_carrier_id,
        carrier_name,
        count(shipment_id)                                              as total_shipments,
        countIf(shipment_status = 'delivered')                          as delivered_count,
        countIf(shipment_status = 'returned')                           as returned_count,
        countIf(shipment_status in ('shipped', 'in_transit'))           as in_transit_count,
        countIf(shipment_status = 'pending')                            as pending_count,
        round(avg(if(
            shipment_delivered_at is not null and shipment_shipped_at is not null,
            dateDiff('day', shipment_shipped_at, shipment_delivered_at),
            null
        )), 1)                                                          as avg_transit_days,
        min(shipment_shipped_at)                                        as first_shipment_at,
        max(shipment_shipped_at)                                        as last_shipment_at
    from {{ ref('fct_shipments') }}
    group by shipment_carrier_id, carrier_name

),

tracking_by_carrier as (

    select
        s.shipment_carrier_id,
        count(t.tracking_event_id)                                      as total_tracking_events,
        countIf(t.tracking_event_status = 'exception')                  as tracking_exceptions,
        countIf(t.tracking_event_status = 'delivered')                  as tracking_delivered_events,
        count(distinct s.shipment_id)                                   as shipments_with_tracking
    from {{ ref('fct_shipments') }} as s
    left join {{ ref('stg_mkt__tracking_events') }} as t
        on t.tracking_event_shipment_id = s.shipment_id
    group by s.shipment_carrier_id

)

select
    sc.shipment_carrier_id,
    sc.carrier_name,
    sc.total_shipments,
    sc.delivered_count,
    sc.returned_count,
    sc.in_transit_count,
    sc.pending_count,
    if(sc.total_shipments > 0,
       round(sc.delivered_count * 100.0 / sc.total_shipments, 2),
       0)                                                               as delivery_rate_pct,
    if(sc.total_shipments > 0,
       round(sc.returned_count * 100.0 / sc.total_shipments, 2),
       0)                                                               as return_rate_pct,
    sc.avg_transit_days,
    sc.first_shipment_at,
    sc.last_shipment_at,
    coalesce(te.total_tracking_events, 0)                               as total_tracking_events,
    coalesce(te.shipments_with_tracking, 0)                             as shipments_with_tracking,
    coalesce(te.tracking_exceptions, 0)                                 as tracking_exceptions,
    if(sc.total_shipments > 0,
       round(coalesce(te.shipments_with_tracking, 0) * 100.0 / sc.total_shipments, 2),
       0)                                                               as tracking_coverage_pct,
    if(te.total_tracking_events > 0,
       round(te.tracking_exceptions * 100.0 / te.total_tracking_events, 2),
       0)                                                               as exception_rate_pct
from shipments_by_carrier as sc
left join tracking_by_carrier as te
    on te.shipment_carrier_id = sc.shipment_carrier_id
