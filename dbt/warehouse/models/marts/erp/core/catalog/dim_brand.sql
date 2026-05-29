{{
    config(
        materialized='table',
        tags=['core', 'erp', 'dim', 'brand', 'catalog']
    )
}}

select id_brand,
       name as brand_name,
       created_at
from {{ ref('stg_erp__brands') }}