with source as (
    select * from {{ source('marketplace', 'stock_levels') }}
),

renamed as (
    select
        _airbyte_raw_id as stock_level__airbyte_raw_id,
        _airbyte_extracted_at as stock_level__airbyte_extracted_at,
        _airbyte_meta as stock_level__airbyte_meta,
        _airbyte_generation_id as stock_level__airbyte_generation_id,
        id as stock_level_id,
        quantity as stock_level_quantity,
        reserved as stock_level_reserved,
        product_id as stock_level_product_id,
        updated_at as stock_level_updated_at,
        _ab_cdc_lsn as stock_level__ab_cdc_lsn,
        warehouse_id as stock_level_warehouse_id,
        _ab_cdc_deleted_at as stock_level__ab_cdc_deleted_at,
        _ab_cdc_updated_at as stock_level__ab_cdc_updated_at
    from source
)

select * from renamed
