{{ config(materialized='table', engine='MergeTree()', order_by='(id_supplier, evaluation_year)', tags=['reports','procurement','sourcing']) }}
with suppliers as (
    select
        id_supplier, code, name, supplier_type, status, country_code,
        nb_purchase_orders, total_ordered_amount,
        avg_evaluation_score, latest_evaluation_score
    from {{ ref('dim_procurement_suppliers') }}
),
evals as (
    select
        supplier_id, evaluation_year, evaluation_quarter,
        quality_score, delivery_score, responsiveness_score,
        price_score, overall_score, status as eval_status
    from {{ ref('fct_procurement_supplier_evaluations') }}
),
final as (
    select
        s.id_supplier,
        s.code,
        s.name,
        s.supplier_type,
        s.status,
        s.country_code,
        s.nb_purchase_orders,
        s.total_ordered_amount,
        s.avg_evaluation_score,
        s.latest_evaluation_score,
        e.evaluation_year,
        e.evaluation_quarter,
        e.quality_score,
        e.delivery_score,
        e.responsiveness_score,
        e.price_score,
        e.overall_score
    from suppliers as s
    left join evals as e on e.supplier_id = s.id_supplier
)
select * from final
