{{
    config(
        materialized='table',
        tags=['mart', 'market_place', 'catalog'],
        order_by='(brand_id)'
    )
}}

with brands as (

    select
        brand_id,
        brand_name,
        brand_slug,
        brand_country,
        brand_logo_url,
        brand_created_at,
        brand_deleted_at
    from {{ ref('stg_mkt__brands') }}

)

select * from brands
