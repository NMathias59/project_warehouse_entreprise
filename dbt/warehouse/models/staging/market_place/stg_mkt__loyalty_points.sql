with source as (
    select * from {{ source('marketplace', 'loyalty_points') }}
),

renamed as (
    select
        _airbyte_raw_id as loyalty_point__airbyte_raw_id,
        _airbyte_extracted_at as loyalty_point__airbyte_extracted_at,
        _airbyte_meta as loyalty_point__airbyte_meta,
        _airbyte_generation_id as loyalty_point__airbyte_generation_id,
        id as loyalty_point_id,
        balance as loyalty_point_balance,
        updated_at as loyalty_point_updated_at,
        _ab_cdc_lsn as loyalty_point__ab_cdc_lsn,
        customer_id as loyalty_point_customer_id,
        _ab_cdc_deleted_at as loyalty_point__ab_cdc_deleted_at,
        _ab_cdc_updated_at as loyalty_point__ab_cdc_updated_at
    from source
)

select * from renamed
