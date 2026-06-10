with orders as (

    select
        order_id,
        order_status,
        order_ordered_at
    from {{ ref('stg_mkt__orders') }}

),

order_lines as (

    select
        order_line_id,
        order_line_order_id,
        order_line_product_id,
        order_line_quantity,
        order_line_unit_price_ht,
        order_line_unit_price_ttc,
        order_line_vat_rate
    from {{ ref('stg_mkt__order_lines') }}

),

products as (

    select
        product_id,
        product_name
    from {{ ref('stg_mkt__products') }}

),

joined as (

    select
        orders.order_id,
        orders.order_status,
        orders.order_ordered_at,
        order_lines.order_line_id,
        order_lines.order_line_product_id,
        products.product_name,
        order_lines.order_line_quantity,
        order_lines.order_line_unit_price_ht,
        order_lines.order_line_unit_price_ttc,
        order_lines.order_line_vat_rate,
        (order_lines.order_line_quantity * order_lines.order_line_unit_price_ttc) as line_total_ttc
    from orders
    inner join order_lines on orders.order_id = order_lines.order_line_order_id
    left join products on order_lines.order_line_product_id = products.product_id

)

select * from joined
