with source as (
    select * from {{ source('marketplace', 'products') }}
),

renamed as (
    select
        _airbyte_raw_id as product__airbyte_raw_id,
        _airbyte_extracted_at as product__airbyte_extracted_at,
        _airbyte_meta as product__airbyte_meta,
        _airbyte_generation_id as product__airbyte_generation_id,
        id as product_id,
        sku as product_sku,
        name as product_name,
        slug as product_slug,
        specs as product_specs,
        brand_id as product_brand_id,
        is_active as product_is_active,
        weight_kg as product_weight_kg,
        created_at as product_created_at,
        deleted_at as product_deleted_at,
        updated_at as product_updated_at,
        _ab_cdc_lsn as product__ab_cdc_lsn,
        category_id as product_category_id,
        description as product_description,
        _ab_cdc_deleted_at as product__ab_cdc_deleted_at,
        _ab_cdc_updated_at as product__ab_cdc_updated_at
    from source
)

select * from renamed
