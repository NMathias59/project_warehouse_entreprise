{{
    config(
        materialized='table',
        tags=['mart', 'market_place', 'catalog'],
        order_by='(product_id)'
    )
}}

with products as (

    select
        product_id,
        product_sku,
        product_name,
        product_slug,
        product_description,
        product_brand_id,
        product_category_id,
        product_is_active,
        product_weight_kg,
        product_created_at,
        product_deleted_at
    from {{ ref('stg_mkt__products') }}

),

stock as (

    select
        stock_level_product_id,
        sum(stock_level_quantity)                             as total_stock,
        sum(stock_level_reserved)                             as total_reserved,
        sum(stock_level_quantity) - sum(stock_level_reserved) as available_stock
    from {{ ref('stg_mkt__stock_levels') }}
    group by stock_level_product_id

),

sales as (

    select
        order_line_product_id,
        count(order_line_id)                                 as total_sales_count,
        sum(order_line_quantity)                             as total_quantity_sold,
        sum(order_line_unit_price_ttc * order_line_quantity) as total_revenue_ttc
    from {{ ref('stg_mkt__order_lines') }}
    group by order_line_product_id

),

final as (

    select
        products.product_id,
        products.product_sku,
        products.product_name,
        products.product_slug,
        products.product_description,
        products.product_brand_id,
        products.product_category_id,
        products.product_is_active,
        products.product_weight_kg,
        coalesce(stock.total_stock, 0)         as total_stock,
        coalesce(stock.total_reserved, 0)      as total_reserved,
        coalesce(stock.available_stock, 0)     as available_stock,
        coalesce(sales.total_sales_count, 0)   as total_sales_count,
        coalesce(sales.total_quantity_sold, 0) as total_quantity_sold,
        coalesce(sales.total_revenue_ttc, 0)   as total_revenue_ttc,
        products.product_created_at,
        products.product_deleted_at
    from products
    left join stock on products.product_id = stock.stock_level_product_id
    left join sales on products.product_id = sales.order_line_product_id

)

select * from final
