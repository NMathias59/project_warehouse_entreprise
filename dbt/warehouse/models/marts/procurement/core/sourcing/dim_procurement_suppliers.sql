{{ config(materialized='table', engine='MergeTree()', order_by='(id_supplier)', tags=['marts','procurement','dim']) }}
with suppliers as (
    select
        id_supplier, code, name, supplier_type, status, country_code, city,
        currency, is_active, created_at, updated_at
    from {{ ref('stg_procurement__suppliers') }}
),
perf as (
    select
        id_supplier, nb_purchase_orders, nb_po_completed,
        total_ordered_amount, avg_evaluation_score, latest_evaluation_score
    from {{ ref('int_procurement__supplier_performance') }}
)
select
    s.id_supplier,
    s.code,
    s.name,
    s.supplier_type,
    s.status,
    s.country_code,
    s.city,
    s.currency,
    s.is_active,
    s.created_at,
    s.updated_at,
    p.nb_purchase_orders,
    p.nb_po_completed,
    p.total_ordered_amount,
    p.avg_evaluation_score,
    p.latest_evaluation_score
from suppliers as s
left join perf as p on p.id_supplier = s.id_supplier
