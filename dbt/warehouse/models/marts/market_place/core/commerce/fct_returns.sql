{{
    config(
        materialized='table',
        tags=['mart', 'market_place', 'commerce'],
        order_by='(return_requested_at, return_id)'
    )
}}

with returns as (

    select
        return_id,
        return_order_id,
        return_reason,
        return_status,
        return_requested_at,
        return_resolved_at
    from {{ ref('stg_mkt__returns') }}

)

select * from returns
