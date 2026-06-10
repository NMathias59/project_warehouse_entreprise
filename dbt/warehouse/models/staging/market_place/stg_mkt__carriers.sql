with source as (
    select * from {{ source('marketplace', 'carriers') }}
),

renamed as (
    select
        id as carrier_id,
        code as carrier_code,
        name as carrier_name,
        is_active as carrier_is_active,
        created_at as carrier_created_at,
        tracking_url as carrier_tracking_url,
        _ab_cdc_lsn as carrier_cdc_lsn,
        _ab_cdc_deleted_at as carrier_cdc_deleted_at,
        _ab_cdc_updated_at as carrier_cdc_updated_at
    from source
)

select * from renamed