{{ config(materialized='ephemeral', tags=['intermediate', 'market_place']) }}
select
    c.cart_id,
    c.cart_customer_id,
    c.cart_session_key,
    c.cart_created_at,
    c.cart_updated_at,
    c.cart_expires_at,
    count(ci.cart_item_id)                                              as nb_items,
    coalesce(sum(ci.cart_item_quantity), 0)                            as total_quantity,
    coalesce(sum(ci.cart_item_quantity * ci.cart_item_unit_price_ttc), 0) as estimated_cart_value_ttc
from {{ ref('stg_mkt__carts') }} as c
left join {{ ref('stg_mkt__cart_items') }} as ci
    on ci.cart_item_cart_id = c.cart_id
where c.cart__ab_cdc_deleted_at is null
group by
    c.cart_id,
    c.cart_customer_id,
    c.cart_session_key,
    c.cart_created_at,
    c.cart_updated_at,
    c.cart_expires_at
