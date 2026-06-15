with source as (
    select * from {{ source('marketplace', 'promotions') }}
),

renamed as (
    select
        _airbyte_raw_id as promotion__airbyte_raw_id,
        _airbyte_extracted_at as promotion__airbyte_extracted_at,
        _airbyte_meta as promotion__airbyte_meta,
        _airbyte_generation_id as promotion__airbyte_generation_id,
        id as promotion_id,
        name as promotion_name,
        type as promotion_type,
        value as promotion_value,
        ends_at as promotion_ends_at,
        is_active as promotion_is_active,
        starts_at as promotion_starts_at,
        created_at as promotion_created_at,
        deleted_at as promotion_deleted_at,
        _ab_cdc_lsn as promotion__ab_cdc_lsn,
        _ab_cdc_deleted_at as promotion__ab_cdc_deleted_at,
        _ab_cdc_updated_at as promotion__ab_cdc_updated_at
    from source
)

select
    promotion__airbyte_raw_id,
    promotion__airbyte_extracted_at,
    promotion__airbyte_meta,
    promotion__airbyte_generation_id,
    promotion_id,
    promotion_name,
    promotion_type,
    promotion_value,
    promotion_ends_at,
    promotion_is_active,
    promotion_starts_at,
    promotion_created_at,
    promotion_deleted_at,
    promotion__ab_cdc_lsn,
    promotion__ab_cdc_deleted_at,
    promotion__ab_cdc_updated_at
from renamed
