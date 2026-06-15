with source as (
    select * from {{ source('marketplace', 'product_images') }}
),

renamed as (
    select
        _airbyte_raw_id as product_image__airbyte_raw_id,
        _airbyte_extracted_at as product_image__airbyte_extracted_at,
        _airbyte_meta as product_image__airbyte_meta,
        _airbyte_generation_id as product_image__airbyte_generation_id,
        id as product_image_id,
        alt as product_image_alt,
        url as product_image_url,
        position as product_image_position,
        created_at as product_image_created_at,
        is_primary as product_image_is_primary,
        product_id as product_image_product_id,
        _ab_cdc_lsn as product_image__ab_cdc_lsn,
        _ab_cdc_deleted_at as product_image__ab_cdc_deleted_at,
        _ab_cdc_updated_at as product_image__ab_cdc_updated_at
    from source
)

select
    product_image__airbyte_raw_id,
    product_image__airbyte_extracted_at,
    product_image__airbyte_meta,
    product_image__airbyte_generation_id,
    product_image_id,
    product_image_alt,
    product_image_url,
    product_image_position,
    product_image_created_at,
    product_image_is_primary,
    product_image_product_id,
    product_image__ab_cdc_lsn,
    product_image__ab_cdc_deleted_at,
    product_image__ab_cdc_updated_at
from renamed
