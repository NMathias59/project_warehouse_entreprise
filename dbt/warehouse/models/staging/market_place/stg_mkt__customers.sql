with source as (
    select * from {{ source('marketplace', 'customers') }}
),

renamed as (
    select
        _airbyte_raw_id as customer__airbyte_raw_id,
        _airbyte_extracted_at as customer__airbyte_extracted_at,
        _airbyte_meta as customer__airbyte_meta,
        _airbyte_generation_id as customer__airbyte_generation_id,
        id as customer_id,
        phone as customer_phone,
        user_id as customer_user_id,
        birthdate as customer_birthdate,
        last_name as customer_last_name,
        created_at as customer_created_at,
        deleted_at as customer_deleted_at,
        first_name as customer_first_name,
        updated_at as customer_updated_at,
        _ab_cdc_lsn as customer__ab_cdc_lsn,
        _ab_cdc_deleted_at as customer__ab_cdc_deleted_at,
        _ab_cdc_updated_at as customer__ab_cdc_updated_at
    from source
)

select * from renamed
