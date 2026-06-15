with source as (
    select * from {{ source('marketplace', 'carts') }}
),

renamed as (
    select
        _airbyte_raw_id as cart__airbyte_raw_id,
        _airbyte_extracted_at as cart__airbyte_extracted_at,
        _airbyte_meta as cart__airbyte_meta,
        _airbyte_generation_id as cart__airbyte_generation_id,
        id as cart_id,
        created_at as cart_created_at,
        expires_at as cart_expires_at,
        updated_at as cart_updated_at,
        _ab_cdc_lsn as cart__ab_cdc_lsn,
        customer_id as cart_customer_id,
        session_key as cart_session_key,
        _ab_cdc_deleted_at as cart__ab_cdc_deleted_at,
        _ab_cdc_updated_at as cart__ab_cdc_updated_at
    from source
)

select
    cart__airbyte_raw_id,
    cart__airbyte_extracted_at,
    cart__airbyte_meta,
    cart__airbyte_generation_id,
    cart_id,
    cart_created_at,
    cart_expires_at,
    cart_updated_at,
    cart__ab_cdc_lsn,
    cart_customer_id,
    cart_session_key,
    cart__ab_cdc_deleted_at,
    cart__ab_cdc_updated_at
from renamed
