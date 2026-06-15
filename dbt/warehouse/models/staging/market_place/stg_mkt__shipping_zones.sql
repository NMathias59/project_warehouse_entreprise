with source as (
    select * from {{ source('marketplace', 'shipping_zones') }}
),

renamed as (
    select
        _airbyte_raw_id as shipping_zone__airbyte_raw_id,
        _airbyte_extracted_at as shipping_zone__airbyte_extracted_at,
        _airbyte_meta as shipping_zone__airbyte_meta,
        _airbyte_generation_id as shipping_zone__airbyte_generation_id,
        id as shipping_zone_id,
        code as shipping_zone_code,
        name as shipping_zone_name,
        countries as shipping_zone_countries,
        is_active as shipping_zone_is_active,
        created_at as shipping_zone_created_at,
        _ab_cdc_lsn as shipping_zone__ab_cdc_lsn,
        _ab_cdc_deleted_at as shipping_zone__ab_cdc_deleted_at,
        _ab_cdc_updated_at as shipping_zone__ab_cdc_updated_at
    from source
)

select
    shipping_zone__airbyte_raw_id,
    shipping_zone__airbyte_extracted_at,
    shipping_zone__airbyte_meta,
    shipping_zone__airbyte_generation_id,
    shipping_zone_id,
    shipping_zone_code,
    shipping_zone_name,
    shipping_zone_countries,
    shipping_zone_is_active,
    shipping_zone_created_at,
    shipping_zone__ab_cdc_lsn,
    shipping_zone__ab_cdc_deleted_at,
    shipping_zone__ab_cdc_updated_at
from renamed
