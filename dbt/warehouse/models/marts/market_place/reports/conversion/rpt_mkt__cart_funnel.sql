{{ config(
    materialized='table',
    engine='MergeTree()',
    order_by='tuple()',
    tags=['reports', 'market_place', 'conversion']
) }}

with cart_activity as (

    select
        toDate(c.cart_created_at)                                   as cart_date,
        count(distinct c.cart_id)                                   as carts_created,
        countIf(c.nb_items > 0)                                     as carts_non_empty,
        countIf(c.cart_customer_id != '')                           as carts_logged_in,
        countIf(c.nb_items = 0)                                     as carts_empty,
        countIf(c.cart_expires_at is not null
                and c.cart_expires_at < now()
                and c.nb_items > 0)                                 as carts_expired_with_items,
        round(avg(c.estimated_cart_value_ttc), 2)                   as avg_cart_value_ttc,
        round(avg(c.nb_items), 1)                                   as avg_items_per_cart,
        sum(c.estimated_cart_value_ttc)                             as total_cart_value_ttc
    from {{ ref('int_mkt__carts_with_items') }} as c
    group by toDate(c.cart_created_at)

),

daily_orders as (

    select
        toDate(order_ordered_at)                                    as order_date,
        count(distinct order_id)                                    as orders_placed,
        sum(order_total_ttc)                                        as orders_revenue_ttc
    from {{ ref('stg_mkt__orders') }}
    where order_deleted_at is null
      and order_ordered_at is not null
    group by toDate(order_ordered_at)

)

select
    ca.cart_date,
    ca.carts_created,
    ca.carts_non_empty,
    ca.carts_logged_in,
    ca.carts_empty,
    ca.carts_expired_with_items                                     as abandoned_carts,
    ca.avg_cart_value_ttc,
    ca.avg_items_per_cart,
    ca.total_cart_value_ttc,
    coalesce(o.orders_placed, 0)                                    as orders_placed,
    coalesce(o.orders_revenue_ttc, 0)                               as orders_revenue_ttc,
    if(ca.carts_non_empty > 0,
       round(coalesce(o.orders_placed, 0) * 100.0 / ca.carts_non_empty, 2),
       0)                                                           as cart_conversion_rate_pct,
    if(ca.carts_non_empty > 0,
       round(ca.carts_expired_with_items * 100.0 / ca.carts_non_empty, 2),
       0)                                                           as cart_abandonment_rate_pct
from cart_activity as ca
left join daily_orders as o
    on o.order_date = ca.cart_date
