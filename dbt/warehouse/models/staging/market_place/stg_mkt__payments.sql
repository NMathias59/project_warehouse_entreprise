with source as (
    select * from {{ source('marketplace', 'payments') }}
),

renamed as (
    select
        id as payment_id,
        amount as payment_amount,
        status as payment_status,
        paid_at as payment_paid_at,
        currency as payment_currency,
        order_id as payment_order_id,
        created_at as payment_created_at,
        gateway_ref as payment_gateway_ref,
        payment_method_id as payment_method_id,
        _ab_cdc_lsn as payment_cdc_lsan,
        _ab_cdc_deleted_at as payment_cdc_deleted_at,
        _ab_cdc_updated_at as payment_cdc_updated_at
    from source
)

select * from renamed