with source as (
    select * from {{ source('marketplace', 'discount_code_usages') }}
),

renamed as (
    select
        _airbyte_raw_id as discount_code_usage__airbyte_raw_id,
        _airbyte_extracted_at as discount_code_usage__airbyte_extracted_at,
        _airbyte_meta as discount_code_usage__airbyte_meta,
        _airbyte_generation_id as discount_code_usage__airbyte_generation_id,
        id as discount_code_usage_id,
        used_at as discount_code_usage_used_at,
        order_id as discount_code_usage_order_id,
        _ab_cdc_lsn as discount_code_usage__ab_cdc_lsn,
        discount_amount as discount_code_usage_discount_amount,
        discount_code_id as discount_code_usage_discount_code_id,
        _ab_cdc_deleted_at as discount_code_usage__ab_cdc_deleted_at,
        _ab_cdc_updated_at as discount_code_usage__ab_cdc_updated_at
    from source
)

select * from renamed
