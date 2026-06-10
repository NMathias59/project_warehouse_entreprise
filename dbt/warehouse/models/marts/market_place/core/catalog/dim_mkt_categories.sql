{{
    config(
        materialized='table',
        tags=['mart', 'market_place', 'catalog'],
        order_by='(category_id)'
    )
}}

with categories as (

    select
        category_id,
        category_name,
        category_slug,
        category_description,
        category_parent_id,
        category_created_at,
        category_deleted_at
    from {{ ref('stg_mkt__categories') }}

)

select * from categories
