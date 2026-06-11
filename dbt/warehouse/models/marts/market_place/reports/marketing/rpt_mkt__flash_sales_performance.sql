{{ config(
    materialized='table',
    engine='MergeTree()',
    order_by='tuple()',
    tags=['reports', 'market_place', 'marketing']
) }}

with flash_sales as (

    select
        flash_sale_id,
        flash_sale_name,
        flash_sale_product_id,
        flash_sale_price_flash_ht,
        flash_sale_price_flash_ttc,
        flash_sale_vat_rate,
        flash_sale_stock_allocated,
        flash_sale_stock_sold,
        flash_sale_starts_at,
        flash_sale_ends_at,
        flash_sale_is_active
    from {{ ref('stg_mkt__flash_sales') }}
    where flash_sale__ab_cdc_deleted_at is null

),

products as (

    select
        product_id,
        product_name,
        product_sku
    from {{ ref('stg_mkt__products') }}

)

select
    fs.flash_sale_id,
    fs.flash_sale_name,
    fs.flash_sale_product_id,
    p.product_name,
    p.product_sku,
    fs.flash_sale_price_flash_ht,
    fs.flash_sale_price_flash_ttc,
    fs.flash_sale_vat_rate,
    fs.flash_sale_starts_at,
    fs.flash_sale_ends_at,
    dateDiff('hour', fs.flash_sale_starts_at, fs.flash_sale_ends_at)    as duration_hours,
    fs.flash_sale_is_active,
    multiIf(
        fs.flash_sale_starts_at > now(), 'upcoming',
        fs.flash_sale_ends_at < now(),   'ended',
        'active'
    )                                                                   as sale_status,
    fs.flash_sale_stock_allocated,
    fs.flash_sale_stock_sold,
    fs.flash_sale_stock_allocated - fs.flash_sale_stock_sold            as stock_remaining,
    if(fs.flash_sale_stock_allocated > 0,
       round(fs.flash_sale_stock_sold * 100.0 / fs.flash_sale_stock_allocated, 2),
       0)                                                               as sell_through_rate_pct,
    round(fs.flash_sale_stock_sold * fs.flash_sale_price_flash_ttc, 2) as estimated_revenue_ttc
from flash_sales as fs
left join products as p
    on p.product_id = fs.flash_sale_product_id
