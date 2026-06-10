with source as (
    select * from {{ source('marketplace', 'product_tags') }}
),

renamed as (
    select
        _airbyte_raw_id as product_tag__airbyte_raw_id,
        _airbyte_extracted_at as product_tag__airbyte_extracted_at,
        _airbyte_meta as product_tag__airbyte_meta,
        _airbyte_generation_id as product_tag__airbyte_generation_id,
        id as product_tag_id,
        tag_id as product_tag_tag_id,
        product_id as product_tag_product_id,
        _ab_cdc_lsn as product_tag__ab_cdc_lsn,
        _ab_cdc_deleted_at as product_tag__ab_cdc_deleted_at,
        _ab_cdc_updated_at as product_tag__ab_cdc_updated_at
    from source
)

select * from renamed
