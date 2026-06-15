with source as (
    select * from {{ source('marketplace', 'cart_items') }}
),

renamed as (
    select
        _airbyte_raw_id as cart_item__airbyte_raw_id,
        _airbyte_extracted_at as cart_item__airbyte_extracted_at,
        _airbyte_meta as cart_item__airbyte_meta,
        _airbyte_generation_id as cart_item__airbyte_generation_id,
        id as cart_item_id,
        cart_id as cart_item_cart_id,
        added_at as cart_item_added_at,
        quantity as cart_item_quantity,
        product_id as cart_item_product_id,
        _ab_cdc_lsn as cart_item__ab_cdc_lsn,
        unit_price_ttc as cart_item_unit_price_ttc,
        _ab_cdc_deleted_at as cart_item__ab_cdc_deleted_at,
        _ab_cdc_updated_at as cart_item__ab_cdc_updated_at
    from source
)

select
    cart_item__airbyte_raw_id,
    cart_item__airbyte_extracted_at,
    cart_item__airbyte_meta,
    cart_item__airbyte_generation_id,
    cart_item_id,
    cart_item_cart_id,
    cart_item_added_at,
    cart_item_quantity,
    cart_item_product_id,
    cart_item__ab_cdc_lsn,
    cart_item_unit_price_ttc,
    cart_item__ab_cdc_deleted_at,
    cart_item__ab_cdc_updated_at
from renamed
