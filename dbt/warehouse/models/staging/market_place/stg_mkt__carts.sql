with source as (
    select * from {{ source('marketplace', 'carts') }}
),

renamed as (
    select
        id as cart_id,
        created_at as cart_created_at,
        expires_at as cart_expires_at,
        updated_at as cart_updated_at,
        customer_id as cart_customer_id,
        session_key as cart_session_key,
        _ab_cdc_lsn as cart_cdc_lsn,
        _ab_cdc_deleted_at as cart_cdc_deleted_at,
        _ab_cdc_updated_at as cart_cdc_updated_at
    from source
)

select * from renamed