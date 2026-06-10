with source as (
    select * from {{ source('marketplace', 'orders') }}
),

renamed as (
    select
        id as order_id,
        notes as order_notes,
        status as order_status,
        currency as order_currency,
        reference as order_reference,
        total_ttc as order_total_ttc,
        deleted_at as order_deleted_at,
        ordered_at as order_ordered_at,
        updated_at as order_updated_at,
        customer_id as order_customer_id,
        discount_ttc as order_discount_ttc,
        shipping_ttc as order_shipping_ttc,
        subtotal_ttc as order_subtotal_ttc,
        billing_address as order_billing_address,
        shipping_address as order_shipping_address,
        _ab_cdc_lsn as order_cdc_lsn,
        _ab_cdc_deleted_at as order_cdc_deleted_at,
        _ab_cdc_updated_at as order_cdc_updated_at
    from source
)

select * from renamed