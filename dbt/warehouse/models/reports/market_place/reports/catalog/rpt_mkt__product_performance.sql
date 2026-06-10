{{ config(
    materialized='table',
    tags=['reports', 'market_place', 'catalog']
) }}

with products as (

    select
        product_id,
        product_sku,
        product_name,
        product_is_active,
        product_brand_id,
        product_category_id,
        total_sales_count,
        total_quantity_sold,
        total_revenue_ttc,
        total_stock,
        total_reserved,
        available_stock,
        product_created_at,
        product_deleted_at
    from {{ ref('dim_mkt_products') }}

),

reviews_agg as (

    select
        review_product_id,
        count(review_id)                        as reviews_count,
        round(avg(review_rating), 2)            as avg_rating,
        countIf(review_rating >= 4)             as positive_reviews_count,
        countIf(review_rating <= 2)             as negative_reviews_count,
        countIf(review_is_verified = true)      as verified_reviews_count,
        max(review_created_at)                  as last_review_at
    from {{ ref('fct_reviews') }}
    where review_deleted_at is null
    group by review_product_id

),

final as (

    select
        p.product_id,
        p.product_sku,
        p.product_name,
        p.product_brand_id,
        p.product_category_id,
        p.product_is_active,
        p.total_sales_count,
        p.total_quantity_sold,
        p.total_revenue_ttc,
        if(p.total_quantity_sold > 0,
           round(p.total_revenue_ttc / p.total_quantity_sold, 2),
           0)                                                       as avg_selling_price_ttc,
        p.total_stock,
        p.total_reserved,
        p.available_stock,
        coalesce(r.reviews_count, 0)                                as reviews_count,
        coalesce(r.avg_rating, 0)                                   as avg_rating,
        coalesce(r.positive_reviews_count, 0)                       as positive_reviews_count,
        coalesce(r.negative_reviews_count, 0)                       as negative_reviews_count,
        coalesce(r.verified_reviews_count, 0)                       as verified_reviews_count,
        r.last_review_at,
        if(p.available_stock = 0 and p.product_is_active = 1, 1, 0) as is_out_of_stock,
        if(p.product_deleted_at is null, 1, 0)                      as is_listed,
        p.product_created_at
    from products p
    left join reviews_agg r on p.product_id = r.review_product_id

)

select * from final
