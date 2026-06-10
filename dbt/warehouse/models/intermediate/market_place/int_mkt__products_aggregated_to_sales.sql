with order_lines as (

    select
        order_line_id,
        order_line_product_id,
        order_line_quantity,
        order_line_unit_price_ttc
    from {{ ref('stg_mkt__order_lines') }}

),

products as (

    select
        product_id,
        product_name
    from {{ ref('stg_mkt__products') }}

),

products_aggregated_to_sales as (

    select
        products.product_id,
        products.product_name,
        count(order_lines.order_line_id) as total_sales_count,
        sum(order_lines.order_line_quantity) as total_quantity_sold,
        sum(order_lines.order_line_unit_price_ttc * order_lines.order_line_quantity) as total_revenue_ttc
    from products
    left join order_lines on products.product_id = order_lines.order_line_product_id
    group by 1, 2

)

select * from products_aggregated_to_sales
