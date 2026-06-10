{{
    config(
        materialized='table',
        tags=['mart', 'market_place', 'logistics'],
        order_by='(carrier_id)'
    )
}}

with carriers as (

    select
        carrier_id,
        carrier_name,
        carrier_code,
        carrier_is_active,
        carrier_tracking_url,
        carrier_created_at
    from {{ ref('stg_mkt__carriers') }}

)

select * from carriers
