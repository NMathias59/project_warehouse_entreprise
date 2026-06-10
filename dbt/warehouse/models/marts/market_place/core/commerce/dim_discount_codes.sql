{{
    config(
        materialized='table',
        tags=['mart', 'market_place', 'commerce'],
        order_by='(discount_code_id)'
    )
}}

with discount_codes as (

    select
        discount_code_id,
        discount_code_code,
        discount_code_type,
        discount_code_value,
        discount_code_min_order,
        discount_code_max_uses,
        discount_code_used_count,
        discount_code_is_active,
        discount_code_expires_at,
        discount_code_created_at
    from {{ ref('stg_mkt__discount_codes') }}

)

select * from discount_codes
