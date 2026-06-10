with source as (
    select * from {{ source('marketplace', 'carriers') }}
),

renamed as (
    select
        _airbyte_raw_id as carrier__airbyte_raw_id,
        _airbyte_extracted_at as carrier__airbyte_extracted_at,
        _airbyte_meta as carrier__airbyte_meta,
        _airbyte_generation_id as carrier__airbyte_generation_id,
        id as carrier_id,
        code as carrier_code,
        name as carrier_name,
        is_active as carrier_is_active,
        created_at as carrier_created_at,
        _ab_cdc_lsn as carrier__ab_cdc_lsn,
        tracking_url as carrier_tracking_url,
        _ab_cdc_deleted_at as carrier__ab_cdc_deleted_at,
        _ab_cdc_updated_at as carrier__ab_cdc_updated_at
    from source
)

select * from renamed
