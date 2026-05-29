{{ config(materialized='ephemeral', tags=['intermediate', 'erp']) }}

with products as (
    select * from {{ ref('stg_erp__products') }}
),
stock as (
    select * from {{ ref('stg_erp__component_stock') }}
)

select
    p.id_product,
    p.name as product_name,
    p.sku,
    p.is_active,
    p.weight_kg,
    p.category_id,
    sum(s.quantity) as total_stock
from products p
left join stock s on p.id_product = s.component_id
where p.is_active = true
group by p.id_product, p.name, p.sku, p.is_active, p.weight_kg, p.category_id

