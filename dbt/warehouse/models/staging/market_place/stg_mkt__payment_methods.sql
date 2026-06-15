with source as (
    select * from {{ source('marketplace', 'payment_methods') }}
),

renamed as (
    select
        _airbyte_raw_id as payment_method__airbyte_raw_id,
        _airbyte_extracted_at as payment_method__airbyte_extracted_at,
        _airbyte_meta as payment_method__airbyte_meta,
        _airbyte_generation_id as payment_method__airbyte_generation_id,
        id as payment_method_id,
        code as payment_method_code,
        name as payment_method_name,
        is_active as payment_method_is_active,
        created_at as payment_method_created_at,
        _ab_cdc_lsn as payment_method__ab_cdc_lsn,
        _ab_cdc_deleted_at as payment_method__ab_cdc_deleted_at,
        _ab_cdc_updated_at as payment_method__ab_cdc_updated_at
    from source
)

select
    payment_method__airbyte_raw_id,
    payment_method__airbyte_extracted_at,
    payment_method__airbyte_meta,
    payment_method__airbyte_generation_id,
    payment_method_id,
    payment_method_code,
    payment_method_name,
    payment_method_is_active,
    payment_method_created_at,
    payment_method__ab_cdc_lsn,
    payment_method__ab_cdc_deleted_at,
    payment_method__ab_cdc_updated_at
from renamed
