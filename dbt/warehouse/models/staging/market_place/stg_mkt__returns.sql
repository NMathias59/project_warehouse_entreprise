with source as (
    select * from {{ source('marketplace', 'returns') }}
),

renamed as (
    select
        _airbyte_raw_id as return__airbyte_raw_id,
        _airbyte_extracted_at as return__airbyte_extracted_at,
        _airbyte_meta as return__airbyte_meta,
        _airbyte_generation_id as return__airbyte_generation_id,
        id as return_id,
        reason as return_reason,
        status as return_status,
        order_id as return_order_id,
        _ab_cdc_lsn as return__ab_cdc_lsn,
        resolved_at as return_resolved_at,
        requested_at as return_requested_at,
        _ab_cdc_deleted_at as return__ab_cdc_deleted_at,
        _ab_cdc_updated_at as return__ab_cdc_updated_at
    from source
)

select
    return__airbyte_raw_id,
    return__airbyte_extracted_at,
    return__airbyte_meta,
    return__airbyte_generation_id,
    return_id,
    return_reason,
    return_status,
    return_order_id,
    return__ab_cdc_lsn,
    return_resolved_at,
    return_requested_at,
    return__ab_cdc_deleted_at,
    return__ab_cdc_updated_at
from renamed
