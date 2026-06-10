with source as (
    select * from {{ source('marketplace', 'promotion_products') }}
),

renamed as (
    select
        _airbyte_raw_id as promotion_product__airbyte_raw_id,
        _airbyte_extracted_at as promotion_product__airbyte_extracted_at,
        _airbyte_meta as promotion_product__airbyte_meta,
        _airbyte_generation_id as promotion_product__airbyte_generation_id,
        id as promotion_product_id,
        created_at as promotion_product_created_at,
        product_id as promotion_product_product_id,
        _ab_cdc_lsn as promotion_product__ab_cdc_lsn,
        promotion_id as promotion_product_promotion_id,
        _ab_cdc_deleted_at as promotion_product__ab_cdc_deleted_at,
        _ab_cdc_updated_at as promotion_product__ab_cdc_updated_at
    from source
)

select * from renamed
