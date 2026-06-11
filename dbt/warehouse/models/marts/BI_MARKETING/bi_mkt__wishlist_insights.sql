{{ config(
    materialized='table',
    engine='MergeTree()',
    order_by='tuple()',
    tags=['bi', 'marketing']
) }}

select
    wi.wishlist_item_product_id                                          as product_id,
    any(p.product_name)                                                  as product_name,
    any(p.product_sku)                                                   as product_sku,
    count(wi.wishlist_item_id)                                           as wishlist_count,
    count(distinct w.wishlist_customer_id)                               as unique_customers,
    countIf(w.wishlist_is_public = true)                                 as public_wishlist_count,
    min(wi.wishlist_item_added_at)                                       as first_wishlisted_at,
    max(wi.wishlist_item_added_at)                                       as last_wishlisted_at,
    coalesce(max(ps.total_sales_count), 0)                               as total_sales,
    coalesce(max(ps.total_quantity_sold), 0)                             as total_qty_sold,
    if(count(wi.wishlist_item_id) > 0,
       round(coalesce(max(ps.total_sales_count), 0) * 100.0
             / count(wi.wishlist_item_id), 2),
       0)                                                                as wishlist_to_sale_rate_pct,
    if(count(wi.wishlist_item_id) > 0
       and coalesce(max(ps.total_sales_count), 0) = 0, 1, 0)           as is_desired_but_unsold
from {{ ref('stg_mkt__wishlist_items') }} as wi
left join {{ ref('stg_mkt__wishlists') }} as w
    on w.wishlist_id = wi.wishlist_item_wishlist_id
left join {{ ref('stg_mkt__products') }} as p
    on p.product_id = wi.wishlist_item_product_id
left join {{ ref('int_mkt__products_aggregated_to_sales') }} as ps
    on ps.product_id = wi.wishlist_item_product_id
where w.wishlist__ab_cdc_deleted_at is null
  and wi.wishlist_item__ab_cdc_deleted_at is null
  and w.wishlist_deleted_at is null
group by wi.wishlist_item_product_id
