{{ config(
    materialized='table',
    engine='MergeTree()',
    order_by='(customer_id)',
    tags=['reports', 'market_place', 'marketing']
) }}

with loyalty_balances as (

    select
        loyalty_point_customer_id,
        loyalty_point_balance
    from {{ ref('stg_mkt__loyalty_points') }}
    where loyalty_point__ab_cdc_deleted_at is null

),

loyalty_transactions as (

    select
        loyalty_transaction_customer_id,
        count(loyalty_transaction_id)                                   as total_transactions,
        countIf(loyalty_transaction_type = 'earn')                      as earn_transactions,
        countIf(loyalty_transaction_type = 'redeem')                    as redeem_transactions,
        sumIf(loyalty_transaction_points, loyalty_transaction_type = 'earn')   as total_points_earned,
        sumIf(loyalty_transaction_points, loyalty_transaction_type = 'redeem') as total_points_redeemed,
        max(loyalty_transaction_created_at)                             as last_transaction_at
    from {{ ref('stg_mkt__loyalty_transactions') }}
    where loyalty_transaction__ab_cdc_deleted_at is null
    group by loyalty_transaction_customer_id

)

select
    c.customer_id,
    c.customer_first_name,
    c.customer_last_name,
    c.total_orders,
    c.first_order_at,
    c.last_order_at,
    coalesce(lb.loyalty_point_balance, 0)                               as current_balance,
    coalesce(lt.total_transactions, 0)                                  as total_transactions,
    coalesce(lt.earn_transactions, 0)                                   as earn_transactions,
    coalesce(lt.redeem_transactions, 0)                                 as redeem_transactions,
    coalesce(lt.total_points_earned, 0)                                 as total_points_earned,
    coalesce(lt.total_points_redeemed, 0)                               as total_points_redeemed,
    lt.last_transaction_at,
    if(c.total_orders > 0,
       round(coalesce(lt.total_points_earned, 0) / c.total_orders, 1),
       0)                                                               as avg_points_per_order,
    if(coalesce(lt.total_points_earned, 0) > 0,
       round(coalesce(lt.total_points_redeemed, 0) * 100.0
             / coalesce(lt.total_points_earned, 0), 2),
       0)                                                               as redemption_rate_pct
from {{ ref('dim_customers') }} as c
inner join loyalty_balances as lb
    on lb.loyalty_point_customer_id = c.customer_id
left join loyalty_transactions as lt
    on lt.loyalty_transaction_customer_id = c.customer_id
where c.customer_deleted_at is null
