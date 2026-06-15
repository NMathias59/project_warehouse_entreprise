with source as (
    select * from {{ source('marketplace', 'order_lines') }}
),

renamed as (
    select
        _airbyte_raw_id as order_line__airbyte_raw_id,
        _airbyte_extracted_at as order_line__airbyte_extracted_at,
        _airbyte_meta as order_line__airbyte_meta,
        _airbyte_generation_id as order_line__airbyte_generation_id,
        id as order_line_id,
        order_id as order_line_order_id,
        quantity as order_line_quantity,
        vat_rate as order_line_vat_rate,
        total_ttc as order_line_total_ttc,
        created_at as order_line_created_at,
        product_id as order_line_product_id,
        _ab_cdc_lsn as order_line__ab_cdc_lsn,
        product_sku as order_line_product_sku,
        product_name as order_line_product_name,
        unit_price_ht as order_line_unit_price_ht,
        unit_price_ttc as order_line_unit_price_ttc,
        _ab_cdc_deleted_at as order_line__ab_cdc_deleted_at,
        _ab_cdc_updated_at as order_line__ab_cdc_updated_at
    from source
)

select
    order_line__airbyte_raw_id,
    order_line__airbyte_extracted_at,
    order_line__airbyte_meta,
    order_line__airbyte_generation_id,
    order_line_id,
    order_line_order_id,
    order_line_quantity,
    order_line_vat_rate,
    order_line_total_ttc,
    order_line_created_at,
    order_line_product_id,
    order_line__ab_cdc_lsn,
    order_line_product_sku,
    order_line_product_name,
    order_line_unit_price_ht,
    order_line_unit_price_ttc,
    order_line__ab_cdc_deleted_at,
    order_line__ab_cdc_updated_at
from renamed
