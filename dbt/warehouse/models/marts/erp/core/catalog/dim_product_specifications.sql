{{ config(materialized='table', tags=['mart','erp','core','catalog']) }}

select
    id_product_specification as id_product_specification,
    product_id,
    key as spec_name,
    value as spec_value
from {{ ref('stg_erp__product_specifications') }}
