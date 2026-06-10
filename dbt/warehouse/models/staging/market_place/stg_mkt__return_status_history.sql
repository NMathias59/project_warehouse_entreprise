with source as (
    select * from {{ source('marketplace', 'return_status_history') }}
),

renamed as (
    select
        _airbyte_raw_id as return_status_history__airbyte_raw_id,
        _airbyte_extracted_at as return_status_history__airbyte_extracted_at,
        _airbyte_meta as return_status_history__airbyte_meta,
        _airbyte_generation_id as return_status_history__airbyte_generation_id,
        id as return_status_history_id,
        status as return_status_history_status,
        return_id as return_status_history_return_id,
        changed_at as return_status_history_changed_at,
        _ab_cdc_lsn as return_status_history__ab_cdc_lsn,
        _ab_cdc_deleted_at as return_status_history__ab_cdc_deleted_at,
        _ab_cdc_updated_at as return_status_history__ab_cdc_updated_at
    from source
)

select * from renamed
