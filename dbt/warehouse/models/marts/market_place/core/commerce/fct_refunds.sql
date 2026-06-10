{{
    config(
        materialized='table',
        tags=['mart', 'market_place', 'commerce'],
        order_by='(refund_created_at, refund_id)'
    )
}}

with refunds as (

    select
        refund_id,
        refund_order_id,
        refund_amount,
        refund_reason,
        refund_status,
        refund_created_at
    from {{ ref('stg_mkt__refunds') }}

)

select * from refunds
