{{
    config(
        materialized='table',
        tags=['mart', 'market_place', 'logistics'],
        order_by='(stock_level_product_id, stock_level_warehouse_id)'
    )
}}

with stock_levels as (

    select
        stock_level_id,
        stock_level_product_id,
        stock_level_warehouse_id,
        stock_level_quantity,
        stock_level_reserved,
        stock_level_quantity - stock_level_reserved as stock_level_available,
        stock_level_updated_at
    from {{ ref('stg_mkt__stock_levels') }}

),

products as (

    select
        product_id,
        product_name,
        product_sku
    from {{ ref('stg_mkt__products') }}

),

warehouses as (

    select
        warehouse_id,
        warehouse_name
    from {{ ref('stg_mkt__warehouses') }}

),

final as (

    select
        stock_levels.stock_level_id,
        stock_levels.stock_level_product_id,
        products.product_name,
        products.product_sku,
        stock_levels.stock_level_warehouse_id,
        warehouses.warehouse_name,
        stock_levels.stock_level_quantity,
        stock_levels.stock_level_reserved,
        stock_levels.stock_level_available,
        stock_levels.stock_level_updated_at
    from stock_levels
    left join products on stock_levels.stock_level_product_id = products.product_id
    left join warehouses on stock_levels.stock_level_warehouse_id = warehouses.warehouse_id

)

select * from final
