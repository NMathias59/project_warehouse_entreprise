with source as (
    select * from {{ source('marketplace', 'discount_codes') }}
),

renamed as (
    select
        _airbyte_raw_id as discount_code__airbyte_raw_id,
        _airbyte_extracted_at as discount_code__airbyte_extracted_at,
        _airbyte_meta as discount_code__airbyte_meta,
        _airbyte_generation_id as discount_code__airbyte_generation_id,
        id as discount_code_id,
        code as discount_code_code,
        type as discount_code_type,
        value as discount_code_value,
        max_uses as discount_code_max_uses,
        is_active as discount_code_is_active,
        min_order as discount_code_min_order,
        created_at as discount_code_created_at,
        expires_at as discount_code_expires_at,
        used_count as discount_code_used_count,
        _ab_cdc_lsn as discount_code__ab_cdc_lsn,
        _ab_cdc_deleted_at as discount_code__ab_cdc_deleted_at,
        _ab_cdc_updated_at as discount_code__ab_cdc_updated_at
    from source
)

select * from renamed
