with source as (
    select * from {{ source('marketplace', 'warehouses') }}
),

renamed as (
    select
        _airbyte_raw_id as warehouse__airbyte_raw_id,
        _airbyte_extracted_at as warehouse__airbyte_extracted_at,
        _airbyte_meta as warehouse__airbyte_meta,
        _airbyte_generation_id as warehouse__airbyte_generation_id,
        id as warehouse_id,
        city as warehouse_city,
        code as warehouse_code,
        name as warehouse_name,
        address as warehouse_address,
        country as warehouse_country,
        is_active as warehouse_is_active,
        created_at as warehouse_created_at,
        deleted_at as warehouse_deleted_at,
        updated_at as warehouse_updated_at,
        _ab_cdc_lsn as warehouse__ab_cdc_lsn,
        _ab_cdc_deleted_at as warehouse__ab_cdc_deleted_at,
        _ab_cdc_updated_at as warehouse__ab_cdc_updated_at
    from source
)

select * from renamed
