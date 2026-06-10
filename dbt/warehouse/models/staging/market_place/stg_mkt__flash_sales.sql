select
    id as flash_sale_id,
    name as flash_sale_name,
    starts_at as flash_sale_starts_at,
    ends_at as flash_sale_ends_at,
    vat_rate as flash_sale_vat_rate,
    is_active as flash_sale_is_active,
    product_id as flash_sale_product_id,
    stock_sold as flash_sale_stock_sold,
    price_flash_ht as flash_sale_price_ht,
    price_flash_ttc as flash_sale_price_ttc,
    stock_allocated as flash_sale_stock_allocated,
    created_at as flash_sale_created_at,
    deleted_at as flash_sale_deleted_at
from {{ source('marketplace', 'flash_sales') }}
