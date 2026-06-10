{{
    config(
        materialized='table',
        tags=['mart', 'market_place', 'commerce'],
        order_by='(promotion_id)'
    )
}}

with promotions as (

    select
        promotion_id,
        promotion_name,
        promotion_type,
        promotion_value,
        promotion_is_active,
        promotion_starts_at,
        promotion_ends_at,
        promotion_created_at,
        promotion_deleted_at
    from {{ ref('stg_mkt__promotions') }}

)

select * from promotions
