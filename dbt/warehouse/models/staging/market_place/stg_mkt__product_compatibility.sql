with source as (
    select * from {{ source('marketplace', 'product_compatibility') }}
),

renamed as (
    select
        _airbyte_raw_id as product_compatibility__airbyte_raw_id,
        _airbyte_extracted_at as product_compatibility__airbyte_extracted_at,
        _airbyte_meta as product_compatibility__airbyte_meta,
        _airbyte_generation_id as product_compatibility__airbyte_generation_id,
        id as product_compatibility_id,
        note as product_compatibility_note,
        level as product_compatibility_level,
        created_at as product_compatibility_created_at,
        _ab_cdc_lsn as product_compatibility__ab_cdc_lsn,
        specs_match as product_compatibility_specs_match,
        product_a_id as product_compatibility_product_a_id,
        product_b_id as product_compatibility_product_b_id,
        _ab_cdc_deleted_at as product_compatibility__ab_cdc_deleted_at,
        _ab_cdc_updated_at as product_compatibility__ab_cdc_updated_at,
        compatibility_type as product_compatibility_compatibility_type
    from source
)

select * from renamed
