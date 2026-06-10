{{
    config(
        materialized='table',
        tags=['mart', 'market_place', 'customer_service'],
        order_by='(review_created_at, review_id)'
    )
}}

with reviews as (

    select
        review_id,
        review_product_id,
        review_customer_id,
        review_order_line_id,
        review_title,
        review_body,
        review_rating,
        review_is_verified,
        review_created_at,
        review_deleted_at
    from {{ ref('stg_mkt__reviews') }}

),

products as (

    select
        product_id,
        product_name,
        product_sku
    from {{ ref('stg_mkt__products') }}

),

final as (

    select
        reviews.review_id,
        reviews.review_product_id,
        products.product_name,
        products.product_sku,
        reviews.review_customer_id,
        reviews.review_order_line_id,
        reviews.review_title,
        reviews.review_body,
        reviews.review_rating,
        reviews.review_is_verified,
        reviews.review_created_at,
        reviews.review_deleted_at
    from reviews
    left join products on reviews.review_product_id = products.product_id

)

select * from final
