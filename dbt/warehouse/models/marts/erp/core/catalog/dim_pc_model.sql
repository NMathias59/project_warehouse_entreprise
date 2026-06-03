{{ config(materialized='table', tags=['mart','erp','core','catalog']) }}


select
    id_pc_model as id_pc_model,
    code,
    name,
    cast(coalesce(product_id, '') as varchar) as product_id,
    is_active,
    created_at
from {{ ref('stg_erp__pc_models') }}