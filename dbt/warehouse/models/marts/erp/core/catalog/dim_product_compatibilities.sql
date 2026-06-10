{{ config(materialized='table', tags=['mart','erp','core','catalog']) }}

select
    id_product_compatibility as id_product_compatibility,
    product_a_id as product_id,
    product_b_id as compatible_product_id
from {{ ref('stg_erp__product_compatibility') }}
