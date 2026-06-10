{{
    config(
        materialized='table',
        tags=['mart', 'market_place', 'logistics'],
        order_by='(warehouse_id)'
    )
}}

with warehouses as (

    select
        warehouse_id,
        warehouse_name,
        warehouse_code,
        warehouse_is_active,
        warehouse_created_at
    from {{ ref('stg_mkt__warehouses') }}

)

select * from warehouses
