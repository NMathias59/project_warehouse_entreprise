{{ config(
    materialized='table',
    engine='MergeTree()',
    order_by='tuple()',
    tags=['bi', 'marketing']
) }}

with order_lines as (

    select
        order_line_order_id                                              as order_id,
        order_line_product_id                                            as product_id,
        order_line_product_name                                          as product_name,
        order_line_product_sku                                           as product_sku
    from {{ ref('stg_mkt__order_lines') }}
    where order_line__ab_cdc_deleted_at is null
      and order_line_product_id is not null
      and order_line_order_id is not null

),

product_totals as (

    select
        product_id,
        count(distinct order_id)                                         as total_orders
    from order_lines
    group by product_id

),

product_pairs as (

    select
        a.product_id                                                     as product_a_id,
        any(a.product_name)                                              as product_a_name,
        any(a.product_sku)                                               as product_a_sku,
        b.product_id                                                     as product_b_id,
        any(b.product_name)                                              as product_b_name,
        any(b.product_sku)                                               as product_b_sku,
        count(distinct a.order_id)                                       as co_purchase_count
    from order_lines as a
    inner join order_lines as b
        on  a.order_id   = b.order_id
        and a.product_id < b.product_id
    group by a.product_id, b.product_id

)

select
    pp.product_a_id,
    pp.product_a_name,
    pp.product_a_sku,
    pp.product_b_id,
    pp.product_b_name,
    pp.product_b_sku,
    pp.co_purchase_count,
    ta.total_orders                                                      as product_a_total_orders,
    tb.total_orders                                                      as product_b_total_orders,
    round(pp.co_purchase_count * 100.0 / nullIf(ta.total_orders, 0), 2) as affinity_rate_a_pct,
    round(pp.co_purchase_count * 100.0 / nullIf(tb.total_orders, 0), 2) as affinity_rate_b_pct,
    round(
        pp.co_purchase_count * 100.0
        / nullIf(ta.total_orders + tb.total_orders - pp.co_purchase_count, 0),
    2)                                                                   as jaccard_similarity_pct
from product_pairs as pp
left join product_totals as ta on ta.product_id = pp.product_a_id
left join product_totals as tb on tb.product_id = pp.product_b_id
where pp.co_purchase_count >= 2
