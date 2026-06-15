with source as (
    select * from {{ source('marketplace', 'product_specifications') }}
),

renamed as (
    select
        _airbyte_raw_id as product_specification__airbyte_raw_id,
        _airbyte_extracted_at as product_specification__airbyte_extracted_at,
        _airbyte_meta as product_specification__airbyte_meta,
        _airbyte_generation_id as product_specification__airbyte_generation_id,
        id as product_specification_id,
        key as product_specification_key,
        unit as product_specification_unit,
        value as product_specification_value,
        extras as product_specification_extras,
        position as product_specification_position,
        created_at as product_specification_created_at,
        product_id as product_specification_product_id,
        _ab_cdc_lsn as product_specification__ab_cdc_lsn,
        _ab_cdc_deleted_at as product_specification__ab_cdc_deleted_at,
        _ab_cdc_updated_at as product_specification__ab_cdc_updated_at
    from source
)

select
    product_specification__airbyte_raw_id,
    product_specification__airbyte_extracted_at,
    product_specification__airbyte_meta,
    product_specification__airbyte_generation_id,
    product_specification_id,
    product_specification_key,
    product_specification_unit,
    product_specification_value,
    product_specification_extras,
    product_specification_position,
    product_specification_created_at,
    product_specification_product_id,
    product_specification__ab_cdc_lsn,
    product_specification__ab_cdc_deleted_at,
    product_specification__ab_cdc_updated_at
from renamed
