{{ config(materialized='ephemeral', tags=['intermediate', 'procurement']) }}

with suppliers as (
    select * from {{ ref('stg_procurement__suppliers') }}
),

purchase_orders as (
    select * from {{ ref('stg_procurement__purchase_orders') }}
),

supplier_evaluations as (
    select * from {{ ref('stg_procurement__supplier_evaluations') }}
)

select
    s.id_supplier,
    s.code,
    s.name,
    s.supplier_type,
    s.status,
    s.country_code,
    s.currency,
    count(distinct po.id_purchase_order)                                    as nb_purchase_orders,
    countIf(po.status = 'received')                                         as nb_po_completed,
    countIf(po.status = 'cancelled')                                        as nb_po_cancelled,
    sum(po.total_amount)                                                    as total_ordered_amount,
    avg(se.overall_score)                                                   as avg_evaluation_score,
    argMax(se.overall_score, se.created_at)                                 as latest_evaluation_score,
    argMax(se.evaluation_year, se.created_at)                               as latest_evaluation_year
from suppliers as s
left join purchase_orders as po
    on po.supplier_id = s.id_supplier
left join supplier_evaluations as se
    on se.supplier_id = s.id_supplier
group by
    s.id_supplier,
    s.code,
    s.name,
    s.supplier_type,
    s.status,
    s.country_code,
    s.currency
