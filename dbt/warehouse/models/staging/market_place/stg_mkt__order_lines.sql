with source as (
    select * from {{ source('marketplace', 'order_lines') }}
),

renamed as (
    select
        id as order_line_id,
        order_id as order_line_order_id,
        quantity as order_line_quantity,
        vat_rate as order_line_vat_rate,
        total_ttc as order_line_total_ttc,
        created_at as order_line_created_at,
        product_id as order_line_product_id,
        product_sku as order_line_product_sku,
        product_name as order_line_product_name,
        unit_price_ht as order_line_unit_price_ht,
        unit_price_ttc as order_line_unit_price_ttc,
        _ab_cdc_lsn as order_line_cdc_lsn,
        _ab_cdc_deleted_at as order_line_cdc_deleted_at,
        _ab_cdc_updated_at as order_line_cdc_updated_at
    from source
)

select * from renamed