{{ config(
    materialized='table',
    tags=['reports', 'market_place', 'logistics']
) }}

with shipments as (

    select
        shipment_id,
        shipment_order_id,
        shipment_carrier_id,
        carrier_name,
        shipment_status,
        shipment_tracking_number,
        shipment_shipped_at,
        shipment_delivered_at,
        shipment_created_at
    from {{ ref('fct_shipments') }}

),

orders_level as (

    select
        order_id,
        max(order_customer_id)  as order_customer_id,
        max(order_status)       as order_status,
        max(order_currency)     as order_currency,
        max(order_ordered_at)   as order_ordered_at,
        max(order_total_ttc)    as order_total_ttc
    from {{ ref('fct_orders') }}
    group by order_id

),

final as (

    select
        s.shipment_id,
        s.shipment_order_id,
        s.shipment_carrier_id,
        s.carrier_name,
        s.shipment_status,
        s.shipment_tracking_number,
        o.order_customer_id,
        o.order_status,
        o.order_currency,
        o.order_total_ttc,
        o.order_ordered_at,
        s.shipment_shipped_at,
        s.shipment_delivered_at,
        if(s.shipment_shipped_at is not null and o.order_ordered_at is not null,
           dateDiff('day', o.order_ordered_at, s.shipment_shipped_at),
           null)                                                         as fulfillment_days,
        if(s.shipment_delivered_at is not null and s.shipment_shipped_at is not null,
           dateDiff('day', s.shipment_shipped_at, s.shipment_delivered_at),
           null)                                                         as transit_days,
        if(s.shipment_delivered_at is not null and o.order_ordered_at is not null,
           dateDiff('day', o.order_ordered_at, s.shipment_delivered_at),
           null)                                                         as total_delivery_days,
        if(s.shipment_delivered_at is not null, 1, 0)                   as is_delivered,
        if(s.shipment_status = 'returned', 1, 0)                        as is_returned,
        toDate(s.shipment_created_at)                                    as shipment_date,
        toYYYYMM(toDate(s.shipment_created_at))                          as shipment_month
    from shipments s
    left join orders_level o on s.shipment_order_id = o.order_id

)

select * from final
