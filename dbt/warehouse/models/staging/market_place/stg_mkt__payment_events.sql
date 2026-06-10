with source as (
    select * from {{ source('marketplace', 'payment_events') }}
),

renamed as (
    select
        _airbyte_raw_id as payment_event__airbyte_raw_id,
        _airbyte_extracted_at as payment_event__airbyte_extracted_at,
        _airbyte_meta as payment_event__airbyte_meta,
        _airbyte_generation_id as payment_event__airbyte_generation_id,
        id as payment_event_id,
        processed as payment_event_processed,
        event_type as payment_event_event_type,
        payment_id as payment_event_payment_id,
        _ab_cdc_lsn as payment_event__ab_cdc_lsn,
        raw_payload as payment_event_raw_payload,
        received_at as payment_event_received_at,
        _ab_cdc_deleted_at as payment_event__ab_cdc_deleted_at,
        _ab_cdc_updated_at as payment_event__ab_cdc_updated_at
    from source
)

select * from renamed
