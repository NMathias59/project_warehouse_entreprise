with source as (
    select * from {{ source('marketplace', 'refunds') }}
),

renamed as (
    select
        _airbyte_raw_id as refund__airbyte_raw_id,
        _airbyte_extracted_at as refund__airbyte_extracted_at,
        _airbyte_meta as refund__airbyte_meta,
        _airbyte_generation_id as refund__airbyte_generation_id,
        id as refund_id,
        amount as refund_amount,
        reason as refund_reason,
        status as refund_status,
        order_id as refund_order_id,
        created_at as refund_created_at,
        _ab_cdc_lsn as refund__ab_cdc_lsn,
        _ab_cdc_deleted_at as refund__ab_cdc_deleted_at,
        _ab_cdc_updated_at as refund__ab_cdc_updated_at
    from source
)

select * from renamed
