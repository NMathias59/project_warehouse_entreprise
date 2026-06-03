{{ config(materialized='table', tags=['mart','erp','core','catalog']) }}

select
    id_product,
    product_name,
    sku,
    is_active,
    weight_kg,
    category_id,
    total_stock

from {{ ref('int_erp__product_stock_summary') }}