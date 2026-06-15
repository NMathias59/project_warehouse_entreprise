with source as (
    select * from {{ source('marketplace', 'tags') }}
),

renamed as (
    select
        _airbyte_raw_id as tag__airbyte_raw_id,
        _airbyte_extracted_at as tag__airbyte_extracted_at,
        _airbyte_meta as tag__airbyte_meta,
        _airbyte_generation_id as tag__airbyte_generation_id,
        id as tag_id,
        name as tag_name,
        slug as tag_slug,
        created_at as tag_created_at,
        _ab_cdc_lsn as tag__ab_cdc_lsn,
        _ab_cdc_deleted_at as tag__ab_cdc_deleted_at,
        _ab_cdc_updated_at as tag__ab_cdc_updated_at
    from source
)

select
    tag__airbyte_raw_id,
    tag__airbyte_extracted_at,
    tag__airbyte_meta,
    tag__airbyte_generation_id,
    tag_id,
    tag_name,
    tag_slug,
    tag_created_at,
    tag__ab_cdc_lsn,
    tag__ab_cdc_deleted_at,
    tag__ab_cdc_updated_at
from renamed
