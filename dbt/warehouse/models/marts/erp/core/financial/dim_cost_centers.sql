{{
config(
    materialized='table',
    tags=['core','mart','dim','erp','financial']
)
}}
select
    id_cost_center,
    name,
    code,
    created_at
from {{ ref('stg_erp__cost_centers') }}