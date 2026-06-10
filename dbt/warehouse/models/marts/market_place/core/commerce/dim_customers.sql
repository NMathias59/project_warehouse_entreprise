{{
    config(
        materialized='table',
        tags=['mart', 'market_place', 'commerce'],
        order_by='(customer_id)'
    )
}}

with customers as (

    select
        customer_id,
        customer_first_name,
        customer_last_name,
        customer_phone,
        customer_birthdate,
        customer_created_at,
        customer_deleted_at
    from {{ ref('stg_mkt__customers') }}

),

activity as (

    select
        customer_id,
        total_orders,
        first_order_at,
        last_order_at
    from {{ ref('int_mkt__customers_aggregated_to_orders') }}

),

final as (

    select
        customers.customer_id,
        customers.customer_first_name,
        customers.customer_last_name,
        customers.customer_phone,
        customers.customer_birthdate,
        coalesce(activity.total_orders, 0)  as total_orders,
        activity.first_order_at,
        activity.last_order_at,
        customers.customer_created_at,
        customers.customer_deleted_at
    from customers
    left join activity on customers.customer_id = activity.customer_id

)

select * from final
