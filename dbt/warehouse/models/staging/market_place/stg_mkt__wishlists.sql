with source as (
    select * from {{ source('marketplace', 'wishlists') }}
),

renamed as (
    select
        _airbyte_raw_id as wishlist__airbyte_raw_id,
        _airbyte_extracted_at as wishlist__airbyte_extracted_at,
        _airbyte_meta as wishlist__airbyte_meta,
        _airbyte_generation_id as wishlist__airbyte_generation_id,
        id as wishlist_id,
        name as wishlist_name,
        is_public as wishlist_is_public,
        created_at as wishlist_created_at,
        deleted_at as wishlist_deleted_at,
        _ab_cdc_lsn as wishlist__ab_cdc_lsn,
        customer_id as wishlist_customer_id,
        _ab_cdc_deleted_at as wishlist__ab_cdc_deleted_at,
        _ab_cdc_updated_at as wishlist__ab_cdc_updated_at
    from source
)

select
    wishlist__airbyte_raw_id,
    wishlist__airbyte_extracted_at,
    wishlist__airbyte_meta,
    wishlist__airbyte_generation_id,
    wishlist_id,
    wishlist_name,
    wishlist_is_public,
    wishlist_created_at,
    wishlist_deleted_at,
    wishlist__ab_cdc_lsn,
    wishlist_customer_id,
    wishlist__ab_cdc_deleted_at,
    wishlist__ab_cdc_updated_at
from renamed
