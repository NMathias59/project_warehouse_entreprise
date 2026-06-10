with source as (
    select * from {{ source('marketplace', 'cart_items') }}
),

renamed as (
    select
        id as cart_item_id,
        cart_id as cart_item_cart_id,
        added_at as cart_item_added_at,
        quantity as cart_item_quantity,
        product_id as cart_item_product_id,
        unit_price_ttc as cart_item_unit_price_ttc,
        _ab_cdc_lsn as cart_item_cdc_lsn,
        _ab_cdc_deleted_at as cart_item_cdc_deleted_at,
        _ab_cdc_updated_at as cart_item_cdc_updated_at
    from source
)

select * from renamed