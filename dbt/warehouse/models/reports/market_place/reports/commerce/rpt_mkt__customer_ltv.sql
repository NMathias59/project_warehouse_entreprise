{{ config(
    materialized='table',
    tags=['reports', 'market_place', 'commerce']
) }}

with customers as (

    select
        customer_id,
        customer_first_name,
        customer_last_name,
        customer_phone,
        customer_birthdate,
        customer_created_at,
        customer_deleted_at
    from {{ ref('dim_customers') }}

),

order_customer_map as (

    select
        order_id,
        any(order_customer_id) as order_customer_id
    from {{ ref('fct_orders') }}
    group by order_id

),

orders_by_customer as (

    select
        order_customer_id,
        count(distinct order_id)                    as orders_count,
        sum(order_line_total_ttc)                   as total_spent_ttc,
        min(order_ordered_at)                       as first_order_at,
        max(order_ordered_at)                       as last_order_at,
        countDistinct(order_line_product_id)        as distinct_products_ordered
    from {{ ref('fct_orders') }}
    group by order_customer_id

),

refunds_by_customer as (

    select
        m.order_customer_id,
        count(r.refund_id)                          as refunds_count,
        sum(r.refund_amount)                        as total_refunded_ttc
    from {{ ref('fct_refunds') }} r
    inner join order_customer_map m on r.refund_order_id = m.order_id
    group by m.order_customer_id

),

final as (

    select
        c.customer_id,
        c.customer_first_name,
        c.customer_last_name,
        c.customer_phone,
        c.customer_created_at,
        if(c.customer_deleted_at is null, 1, 0)                 as is_active,
        coalesce(o.orders_count, 0)                             as orders_count,
        coalesce(o.total_spent_ttc, 0)                          as total_spent_ttc,
        coalesce(r.total_refunded_ttc, 0)                       as total_refunded_ttc,
        coalesce(o.total_spent_ttc, 0)
            - coalesce(r.total_refunded_ttc, 0)                 as net_ltv_ttc,
        if(o.orders_count > 0,
           o.total_spent_ttc / o.orders_count, 0)               as avg_order_value_ttc,
        coalesce(r.refunds_count, 0)                            as refunds_count,
        coalesce(o.distinct_products_ordered, 0)                as distinct_products_ordered,
        o.first_order_at,
        o.last_order_at,
        if(o.first_order_at is not null and o.last_order_at is not null,
           dateDiff('day', o.first_order_at, o.last_order_at),
           null)                                                as customer_lifespan_days,
        case
            when coalesce(o.orders_count, 0) = 0   then 'prospect'
            when coalesce(o.orders_count, 0) = 1   then 'one_time'
            when coalesce(o.orders_count, 0) <= 3  then 'occasional'
            else 'loyal'
        end                                                     as customer_segment
    from customers c
    left join orders_by_customer o on c.customer_id = o.order_customer_id
    left join refunds_by_customer r on c.customer_id = r.order_customer_id

)

select * from final
