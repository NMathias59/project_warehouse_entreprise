with source as (
    select * from {{ source('marketplace', 'shipments') }}
),

renamed as (
    select
        _airbyte_raw_id as shipment__airbyte_raw_id,
        _airbyte_extracted_at as shipment__airbyte_extracted_at,
        _airbyte_meta as shipment__airbyte_meta,
        _airbyte_generation_id as shipment__airbyte_generation_id,
        id as shipment_id,
        status as shipment_status,
        order_id as shipment_order_id,
        carrier_id as shipment_carrier_id,
        created_at as shipment_created_at,
        shipped_at as shipment_shipped_at,
        _ab_cdc_lsn as shipment__ab_cdc_lsn,
        delivered_at as shipment_delivered_at,
        tracking_number as shipment_tracking_number,
        _ab_cdc_deleted_at as shipment__ab_cdc_deleted_at,
        _ab_cdc_updated_at as shipment__ab_cdc_updated_at
    from source
)

select
    shipment__airbyte_raw_id,
    shipment__airbyte_extracted_at,
    shipment__airbyte_meta,
    shipment__airbyte_generation_id,
    shipment_id,
    shipment_status,
    shipment_order_id,
    shipment_carrier_id,
    shipment_created_at,
    shipment_shipped_at,
    shipment__ab_cdc_lsn,
    shipment_delivered_at,
    shipment_tracking_number,
    shipment__ab_cdc_deleted_at,
    shipment__ab_cdc_updated_at
from renamed
