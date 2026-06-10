with source as (
    select * from {{ source('marketplace', 'brands') }}
),

renamed as (
    select
        id as brand_id,
        name as brand_name,
        slug as brand_slug,
        country as brand_country,
        logo_url as brand_logo_url,
        created_at as brand_created_at,
        updated_at as brand_updated_at,
        deleted_at as brand_deleted_at,
        _ab_cdc_lsn as brand_cdc_lsn,
        _ab_cdc_deleted_at as brand_cdc_deleted_at,
        _ab_cdc_updated_at as brand_cdc_updated_at
    from source
)

select * from renamed