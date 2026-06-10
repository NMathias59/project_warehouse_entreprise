with source as (
    select * from {{ source('marketplace', 'pc_bundle_lines') }}
),

renamed as (
    select
        _airbyte_raw_id as pc_bundle_line__airbyte_raw_id,
        _airbyte_extracted_at as pc_bundle_line__airbyte_extracted_at,
        _airbyte_meta as pc_bundle_line__airbyte_meta,
        _airbyte_generation_id as pc_bundle_line__airbyte_generation_id,
        id as pc_bundle_line_id,
        position as pc_bundle_line_position,
        quantity as pc_bundle_line_quantity,
        bundle_id as pc_bundle_line_bundle_id,
        product_id as pc_bundle_line_product_id,
        _ab_cdc_lsn as pc_bundle_line__ab_cdc_lsn,
        _ab_cdc_deleted_at as pc_bundle_line__ab_cdc_deleted_at,
        _ab_cdc_updated_at as pc_bundle_line__ab_cdc_updated_at
    from source
)

select * from renamed
