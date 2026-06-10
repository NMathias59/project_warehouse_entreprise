with source as (
    select * from {{ source('marketplace', 'order_status_history') }}
),

renamed as (
    select
        _airbyte_raw_id as order_status_history__airbyte_raw_id,
        _airbyte_extracted_at as order_status_history__airbyte_extracted_at,
        _airbyte_meta as order_status_history__airbyte_meta,
        _airbyte_generation_id as order_status_history__airbyte_generation_id,
        id as order_status_history_id,
        status as order_status_history_status,
        comment as order_status_history_comment,
        order_id as order_status_history_order_id,
        changed_at as order_status_history_changed_at,
        changed_by as order_status_history_changed_by,
        _ab_cdc_lsn as order_status_history__ab_cdc_lsn,
        _ab_cdc_deleted_at as order_status_history__ab_cdc_deleted_at,
        _ab_cdc_updated_at as order_status_history__ab_cdc_updated_at
    from source
)

select * from renamed
