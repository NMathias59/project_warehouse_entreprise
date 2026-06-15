with source as (
    select * from {{ source('marketplace', 'orders') }}
),

renamed as (
    select
        _airbyte_raw_id as order__airbyte_raw_id,
        _airbyte_extracted_at as order__airbyte_extracted_at,
        _airbyte_meta as order__airbyte_meta,
        _airbyte_generation_id as order__airbyte_generation_id,
        id as order_id,
        notes as order_notes,
        status as order_status,
        currency as order_currency,
        reference as order_reference,
        total_ttc as order_total_ttc,
        deleted_at as order_deleted_at,
        ordered_at as order_ordered_at,
        updated_at as order_updated_at,
        _ab_cdc_lsn as order__ab_cdc_lsn,
        customer_id as order_customer_id,
        discount_ttc as order_discount_ttc,
        shipping_ttc as order_shipping_ttc,
        subtotal_ttc as order_subtotal_ttc,
        billing_address as order_billing_address,
        shipping_address as order_shipping_address,
        _ab_cdc_deleted_at as order__ab_cdc_deleted_at,
        _ab_cdc_updated_at as order__ab_cdc_updated_at
    from source
)

select
    order__airbyte_raw_id,
    order__airbyte_extracted_at,
    order__airbyte_meta,
    order__airbyte_generation_id,
    order_id,
    order_notes,
    order_status,
    order_currency,
    order_reference,
    order_total_ttc,
    order_deleted_at,
    order_ordered_at,
    order_updated_at,
    order__ab_cdc_lsn,
    order_customer_id,
    order_discount_ttc,
    order_shipping_ttc,
    order_subtotal_ttc,
    order_billing_address,
    order_shipping_address,
    order__ab_cdc_deleted_at,
    order__ab_cdc_updated_at
from renamed
