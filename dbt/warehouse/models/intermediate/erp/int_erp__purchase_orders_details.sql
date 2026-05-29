{{ config(materialized='ephemeral', tags=['intermediate', 'erp']) }}

with pol as (
    select * from {{ ref('stg_erp__purchase_order_lines') }}
),
po as (
    select * from {{ ref('stg_erp__purchase_orders') }}
),
products as (
    select * from {{ ref('stg_erp__products') }}
),
suppliers as (
    select * from {{ ref('stg_erp__suppliers') }}
)

select
    po.id_purchase_order,
    po.status,
    po.currency,
    po.created_at,
    po.ordered_at,
    po.expected_at,
    po.supplier_id,
    s.name as supplier_name,
    pol.id_purchase_order_line,
    pol.quantity,
    pol.total_ht as line_total_ht,
    pol.unit_price,
    pol.component_id,
    pr.name as product_name
from po
left join pol on po.id_purchase_order = pol.purchase_order_id
left join suppliers s on po.supplier_id = s.id_supplier
left join products pr on pol.component_id = pr.id_product

