with customers as (

    select
        customer_id,
        customer_first_name,
        customer_last_name
    from {{ ref('stg_mkt__customers') }}

),

orders as (

    select
        order_id,
        order_customer_id,
        order_ordered_at
    from {{ ref('stg_mkt__orders') }}

),

customers_aggregated_to_orders as (

    select
        customers.customer_id,
        customers.customer_first_name,
        customers.customer_last_name,
        count(orders.order_id) as total_orders,
        min(orders.order_ordered_at) as first_order_at,
        max(orders.order_ordered_at) as last_order_at
    from customers
    left join orders on customers.customer_id = orders.order_customer_id
    group by 1, 2, 3

)

select * from customers_aggregated_to_orders
