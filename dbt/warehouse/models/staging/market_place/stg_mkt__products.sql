with source as (
    select * from {{ source('marketplace', 'products') }}
),

renamed as (
    select
        id as product_id,
        sku as product_sku,
        name as product_name,
        slug as product_slug,
        brand_id as product_brand_id,
        category_id as product_category_id,
        description as product_description,
        is_active as product_is_active,
        weight_kg as product_weight_kg,
        created_at as product_created_at,
        updated_at as product_updated_at,
        deleted_at as product_deleted_at,
        _ab_cdc_lsn as product_cdc_lsn,
        _ab_cdc_deleted_at as product_cdc_deleted_at,
        _ab_cdc_updated_at as product_cdc_updated_at
    from source
)

select * from renamed