with source as (
    select * from {{ source('marketplace', 'shipping_rates') }}
),

renamed as (
    select
        _airbyte_raw_id as shipping_rate__airbyte_raw_id,
        _airbyte_extracted_at as shipping_rate__airbyte_extracted_at,
        _airbyte_meta as shipping_rate__airbyte_meta,
        _airbyte_generation_id as shipping_rate__airbyte_generation_id,
        id as shipping_rate_id,
        price as shipping_rate_price,
        zone_id as shipping_rate_zone_id,
        currency as shipping_rate_currency,
        method_id as shipping_rate_method_id,
        created_at as shipping_rate_created_at,
        _ab_cdc_lsn as shipping_rate__ab_cdc_lsn,
        max_weight_kg as shipping_rate_max_weight_kg,
        min_weight_kg as shipping_rate_min_weight_kg,
        _ab_cdc_deleted_at as shipping_rate__ab_cdc_deleted_at,
        _ab_cdc_updated_at as shipping_rate__ab_cdc_updated_at
    from source
)

select
    shipping_rate__airbyte_raw_id,
    shipping_rate__airbyte_extracted_at,
    shipping_rate__airbyte_meta,
    shipping_rate__airbyte_generation_id,
    shipping_rate_id,
    shipping_rate_price,
    shipping_rate_zone_id,
    shipping_rate_currency,
    shipping_rate_method_id,
    shipping_rate_created_at,
    shipping_rate__ab_cdc_lsn,
    shipping_rate_max_weight_kg,
    shipping_rate_min_weight_kg,
    shipping_rate__ab_cdc_deleted_at,
    shipping_rate__ab_cdc_updated_at
from renamed
