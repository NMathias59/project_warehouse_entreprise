with source as (
    select * from {{ source('marketplace', 'wishlist_items') }}
),

renamed as (
    select
        _airbyte_raw_id as wishlist_item__airbyte_raw_id,
        _airbyte_extracted_at as wishlist_item__airbyte_extracted_at,
        _airbyte_meta as wishlist_item__airbyte_meta,
        _airbyte_generation_id as wishlist_item__airbyte_generation_id,
        id as wishlist_item_id,
        added_at as wishlist_item_added_at,
        product_id as wishlist_item_product_id,
        _ab_cdc_lsn as wishlist_item__ab_cdc_lsn,
        wishlist_id as wishlist_item_wishlist_id,
        _ab_cdc_deleted_at as wishlist_item__ab_cdc_deleted_at,
        _ab_cdc_updated_at as wishlist_item__ab_cdc_updated_at
    from source
)

select * from renamed
