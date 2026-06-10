{{
    config(
        materialized='table',
        tags=['mart', 'market_place', 'logistics'],
        order_by='(shipping_method_id)'
    )
}}

with shipping_methods as (

    select
        shipping_method_id,
        shipping_method_name,
        shipping_method_code,
        shipping_method_carrier_id,
        shipping_method_is_active,
        shipping_method_estimated_days_min,
        shipping_method_estimated_days_max,
        shipping_method_created_at
    from {{ ref('stg_mkt__shipping_methods') }}

)

select * from shipping_methods
