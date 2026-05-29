{{ config(materialized='ephemeral', tags=['intermediate', 'erp']) }}

with suppliers as (
    select * from {{ ref('stg_erp__suppliers') }}
),
purchase_orders as (
    select * from {{ ref('stg_erp__purchase_orders') }}
)

select
    s.id_supplier,
    s.name as supplier_name,
    s.country,
    s.is_active,
    count(po.id_purchase_order) as nb_purchase_orders,
    sum(po.total_ht) as total_purchase_ht
from suppliers s
left join purchase_orders po on s.id_supplier = po.supplier_id
group by s.id_supplier, s.name, s.country, s.is_active

