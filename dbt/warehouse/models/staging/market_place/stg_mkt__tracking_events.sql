with source as (
    select * from {{ source('marketplace', 'tracking_events') }}
),

renamed as (
    select
        _airbyte_raw_id as tracking_event__airbyte_raw_id,
        _airbyte_extracted_at as tracking_event__airbyte_extracted_at,
        _airbyte_meta as tracking_event__airbyte_meta,
        _airbyte_generation_id as tracking_event__airbyte_generation_id,
        id as tracking_event_id,
        status as tracking_event_status,
        location as tracking_event_location,
        _ab_cdc_lsn as tracking_event__ab_cdc_lsn,
        description as tracking_event_description,
        occurred_at as tracking_event_occurred_at,
        shipment_id as tracking_event_shipment_id,
        _ab_cdc_deleted_at as tracking_event__ab_cdc_deleted_at,
        _ab_cdc_updated_at as tracking_event__ab_cdc_updated_at
    from source
)

select
    tracking_event__airbyte_raw_id,
    tracking_event__airbyte_extracted_at,
    tracking_event__airbyte_meta,
    tracking_event__airbyte_generation_id,
    tracking_event_id,
    tracking_event_status,
    tracking_event_location,
    tracking_event__ab_cdc_lsn,
    tracking_event_description,
    tracking_event_occurred_at,
    tracking_event_shipment_id,
    tracking_event__ab_cdc_deleted_at,
    tracking_event__ab_cdc_updated_at
from renamed
