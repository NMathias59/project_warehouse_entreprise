with source as (
    select * from {{ source('marketplace', 'customers') }}
),

renamed as (
    select
        id as customer_id,
        phone as customer_phone,
        user_id as customer_user_id,
        birthdate as customer_birthdate,
        last_name as customer_last_name,
        first_name as customer_first_name,
        created_at as customer_created_at,
        updated_at as customer_updated_at,
        _ab_cdc_lsn as customer_cdc_lsn,
        _ab_cdc_deleted_at as customer_cdc_deleted_at,
        _ab_cdc_updated_at as customer_cdc_updated_at
    from source
)

select * from renamed