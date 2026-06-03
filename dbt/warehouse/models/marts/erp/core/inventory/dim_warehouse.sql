{{ config(materialized='table', tags=['mart','erp','core']) }}

with w as (
    select * from {{ ref('stg_erp__warehouses') }}
)

select
    id_warehouse as id_warehouse,
    name,
    code,
    is_active,
    created_at,
    updated_at
from w
