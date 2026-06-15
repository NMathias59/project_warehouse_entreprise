with source as (
    select * from {{ source('marketplace', 'product_prices') }}
),

renamed as (
    select
        _airbyte_raw_id as product_price__airbyte_raw_id,
        _airbyte_extracted_at as product_price__airbyte_extracted_at,
        _airbyte_meta as product_price__airbyte_meta,
        _airbyte_generation_id as product_price__airbyte_generation_id,
        id as product_price_id,
        currency as product_price_currency,
        price_ht as product_price_price_ht,
        vat_rate as product_price_vat_rate,
        price_ttc as product_price_price_ttc,
        created_at as product_price_created_at,
        product_id as product_price_product_id,
        valid_from as product_price_valid_from,
        _ab_cdc_lsn as product_price__ab_cdc_lsn,
        valid_until as product_price_valid_until,
        _ab_cdc_deleted_at as product_price__ab_cdc_deleted_at,
        _ab_cdc_updated_at as product_price__ab_cdc_updated_at
    from source
)

select
    product_price__airbyte_raw_id,
    product_price__airbyte_extracted_at,
    product_price__airbyte_meta,
    product_price__airbyte_generation_id,
    product_price_id,
    product_price_currency,
    product_price_price_ht,
    product_price_vat_rate,
    product_price_price_ttc,
    product_price_created_at,
    product_price_product_id,
    product_price_valid_from,
    product_price__ab_cdc_lsn,
    product_price_valid_until,
    product_price__ab_cdc_deleted_at,
    product_price__ab_cdc_updated_at
from renamed
