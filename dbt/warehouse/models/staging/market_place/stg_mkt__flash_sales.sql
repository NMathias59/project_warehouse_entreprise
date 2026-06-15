with source as (
    select * from {{ source('marketplace', 'flash_sales') }}
),

renamed as (
    select
        _airbyte_raw_id as flash_sale__airbyte_raw_id,
        _airbyte_extracted_at as flash_sale__airbyte_extracted_at,
        _airbyte_meta as flash_sale__airbyte_meta,
        _airbyte_generation_id as flash_sale__airbyte_generation_id,
        id as flash_sale_id,
        name as flash_sale_name,
        ends_at as flash_sale_ends_at,
        vat_rate as flash_sale_vat_rate,
        is_active as flash_sale_is_active,
        starts_at as flash_sale_starts_at,
        created_at as flash_sale_created_at,
        deleted_at as flash_sale_deleted_at,
        product_id as flash_sale_product_id,
        stock_sold as flash_sale_stock_sold,
        _ab_cdc_lsn as flash_sale__ab_cdc_lsn,
        price_flash_ht as flash_sale_price_flash_ht,
        price_flash_ttc as flash_sale_price_flash_ttc,
        stock_allocated as flash_sale_stock_allocated,
        _ab_cdc_deleted_at as flash_sale__ab_cdc_deleted_at,
        _ab_cdc_updated_at as flash_sale__ab_cdc_updated_at
    from source
)

select
    flash_sale__airbyte_raw_id,
    flash_sale__airbyte_extracted_at,
    flash_sale__airbyte_meta,
    flash_sale__airbyte_generation_id,
    flash_sale_id,
    flash_sale_name,
    flash_sale_ends_at,
    flash_sale_vat_rate,
    flash_sale_is_active,
    flash_sale_starts_at,
    flash_sale_created_at,
    flash_sale_deleted_at,
    flash_sale_product_id,
    flash_sale_stock_sold,
    flash_sale__ab_cdc_lsn,
    flash_sale_price_flash_ht,
    flash_sale_price_flash_ttc,
    flash_sale_stock_allocated,
    flash_sale__ab_cdc_deleted_at,
    flash_sale__ab_cdc_updated_at
from renamed
