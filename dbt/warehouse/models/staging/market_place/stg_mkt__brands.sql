with source as (
    select * from {{ source('marketplace', 'brands') }}
),

renamed as (
    select
        _airbyte_raw_id as brand__airbyte_raw_id,
        _airbyte_extracted_at as brand__airbyte_extracted_at,
        _airbyte_meta as brand__airbyte_meta,
        _airbyte_generation_id as brand__airbyte_generation_id,
        id as brand_id,
        name as brand_name,
        slug as brand_slug,
        country as brand_country,
        logo_url as brand_logo_url,
        created_at as brand_created_at,
        deleted_at as brand_deleted_at,
        updated_at as brand_updated_at,
        _ab_cdc_lsn as brand__ab_cdc_lsn,
        _ab_cdc_deleted_at as brand__ab_cdc_deleted_at,
        _ab_cdc_updated_at as brand__ab_cdc_updated_at
    from source
)

select
    brand__airbyte_raw_id,
    brand__airbyte_extracted_at,
    brand__airbyte_meta,
    brand__airbyte_generation_id,
    brand_id,
    brand_name,
    brand_slug,
    brand_country,
    brand_logo_url,
    brand_created_at,
    brand_deleted_at,
    brand_updated_at,
    brand__ab_cdc_lsn,
    brand__ab_cdc_deleted_at,
    brand__ab_cdc_updated_at
from renamed
