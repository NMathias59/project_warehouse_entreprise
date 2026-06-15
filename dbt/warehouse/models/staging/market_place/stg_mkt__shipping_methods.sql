with source as (
    select * from {{ source('marketplace', 'shipping_methods') }}
),

renamed as (
    select
        _airbyte_raw_id as shipping_method__airbyte_raw_id,
        _airbyte_extracted_at as shipping_method__airbyte_extracted_at,
        _airbyte_meta as shipping_method__airbyte_meta,
        _airbyte_generation_id as shipping_method__airbyte_generation_id,
        id as shipping_method_id,
        code as shipping_method_code,
        name as shipping_method_name,
        is_active as shipping_method_is_active,
        carrier_id as shipping_method_carrier_id,
        created_at as shipping_method_created_at,
        _ab_cdc_lsn as shipping_method__ab_cdc_lsn,
        _ab_cdc_deleted_at as shipping_method__ab_cdc_deleted_at,
        _ab_cdc_updated_at as shipping_method__ab_cdc_updated_at,
        estimated_days_max as shipping_method_estimated_days_max,
        estimated_days_min as shipping_method_estimated_days_min
    from source
)

select
    shipping_method__airbyte_raw_id,
    shipping_method__airbyte_extracted_at,
    shipping_method__airbyte_meta,
    shipping_method__airbyte_generation_id,
    shipping_method_id,
    shipping_method_code,
    shipping_method_name,
    shipping_method_is_active,
    shipping_method_carrier_id,
    shipping_method_created_at,
    shipping_method__ab_cdc_lsn,
    shipping_method__ab_cdc_deleted_at,
    shipping_method__ab_cdc_updated_at,
    shipping_method_estimated_days_max,
    shipping_method_estimated_days_min
from renamed
