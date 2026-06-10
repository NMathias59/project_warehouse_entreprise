with source as (
    select * from {{ source('marketplace', 'pc_bundles') }}
),

renamed as (
    select
        _airbyte_raw_id as pc_bundle__airbyte_raw_id,
        _airbyte_extracted_at as pc_bundle__airbyte_extracted_at,
        _airbyte_meta as pc_bundle__airbyte_meta,
        _airbyte_generation_id as pc_bundle__airbyte_generation_id,
        id as pc_bundle_id,
        name as pc_bundle_name,
        slug as pc_bundle_slug,
        is_active as pc_bundle_is_active,
        price_ttc as pc_bundle_price_ttc,
        created_at as pc_bundle_created_at,
        deleted_at as pc_bundle_deleted_at,
        _ab_cdc_lsn as pc_bundle__ab_cdc_lsn,
        description as pc_bundle_description,
        _ab_cdc_deleted_at as pc_bundle__ab_cdc_deleted_at,
        _ab_cdc_updated_at as pc_bundle__ab_cdc_updated_at
    from source
)

select * from renamed
