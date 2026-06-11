{{ config(
    materialized='table',
    engine='MergeTree()',
    order_by='(discount_code_id)',
    tags=['reports', 'market_place', 'marketing']
) }}

with usages as (

    select
        discount_code_usage_discount_code_id,
        count(discount_code_usage_id)               as actual_uses,
        sum(discount_code_usage_discount_amount)    as total_discount_granted,
        min(discount_code_usage_used_at)            as first_used_at,
        max(discount_code_usage_used_at)            as last_used_at
    from {{ ref('stg_mkt__discount_code_usages') }}
    group by discount_code_usage_discount_code_id

),

revenue_per_code as (

    select
        u.discount_code_usage_discount_code_id,
        sum(o.order_total_ttc)                      as revenue_with_code,
        count(distinct u.discount_code_usage_order_id) as orders_with_code
    from {{ ref('stg_mkt__discount_code_usages') }} as u
    left join {{ ref('stg_mkt__orders') }} as o
        on o.order_id = u.discount_code_usage_order_id
    where o.order_deleted_at is null
    group by u.discount_code_usage_discount_code_id

)

select
    dc.discount_code_id,
    dc.discount_code_code                                                           as code,
    dc.discount_code_type                                                           as discount_type,
    dc.discount_code_value                                                          as discount_value,
    dc.discount_code_is_active                                                      as is_active,
    dc.discount_code_min_order                                                      as min_order_amount,
    dc.discount_code_max_uses                                                       as max_uses,
    dc.discount_code_expires_at                                                     as expires_at,
    coalesce(u.actual_uses, 0)                                                      as actual_uses,
    greatest(coalesce(dc.discount_code_max_uses, 0) - coalesce(u.actual_uses, 0), 0) as remaining_uses,
    if(dc.discount_code_max_uses > 0,
       round(coalesce(u.actual_uses, 0) * 100.0 / dc.discount_code_max_uses, 2),
       null)                                                                        as usage_rate_pct,
    coalesce(u.total_discount_granted, 0)                                          as total_discount_granted,
    coalesce(r.revenue_with_code, 0)                                               as revenue_with_code,
    coalesce(r.orders_with_code, 0)                                                as orders_with_code,
    u.first_used_at,
    u.last_used_at
from {{ ref('stg_mkt__discount_codes') }} as dc
left join usages as u
    on u.discount_code_usage_discount_code_id = dc.discount_code_id
left join revenue_per_code as r
    on r.discount_code_usage_discount_code_id = dc.discount_code_id
where dc.discount_code__ab_cdc_deleted_at is null
