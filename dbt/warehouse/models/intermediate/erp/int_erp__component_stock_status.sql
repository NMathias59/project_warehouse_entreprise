{{ config(materialized='ephemeral', tags=['intermediate', 'erp']) }}

with stock as (
    select * from {{ ref('stg_erp__component_stock') }}
),
components as (
    select * from {{ ref('stg_erp__components') }}
)

select
    c.id_components as component_id,
    c.name as component_name,
    c.unit,
    c.is_active,
    c.max_stock,
    c.min_stock,
    s.quantity as current_stock,
    s.location_id,
    s.updated_at as stock_updated_at
from components c
left join stock s on c.id_components = s.component_id

