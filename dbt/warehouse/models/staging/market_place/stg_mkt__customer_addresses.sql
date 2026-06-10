with source as (
    select * from {{ source('marketplace', 'customer_addresses') }}
),

renamed as (
    select
        _airbyte_raw_id as customer_addresse__airbyte_raw_id,
        _airbyte_extracted_at as customer_addresse__airbyte_extracted_at,
        _airbyte_meta as customer_addresse__airbyte_meta,
        _airbyte_generation_id as customer_addresse__airbyte_generation_id,
        id as customer_addresse_id,
        city as customer_addresse_city,
        label as customer_addresse_label,
        street as customer_addresse_street,
        last_name as customer_addresse_last_name,
        created_at as customer_addresse_created_at,
        deleted_at as customer_addresse_deleted_at,
        first_name as customer_addresse_first_name,
        is_default as customer_addresse_is_default,
        _ab_cdc_lsn as customer_addresse__ab_cdc_lsn,
        customer_id as customer_addresse_customer_id,
        postal_code as customer_addresse_postal_code,
        country_code as customer_addresse_country_code,
        _ab_cdc_deleted_at as customer_addresse__ab_cdc_deleted_at,
        _ab_cdc_updated_at as customer_addresse__ab_cdc_updated_at
    from source
)

select * from renamed
