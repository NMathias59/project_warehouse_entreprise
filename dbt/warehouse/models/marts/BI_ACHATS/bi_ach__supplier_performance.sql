{{ config(
    materialized='table',
    engine='MergeTree()',
    order_by='(id_supplier)',
    tags=['bi', 'achats']
) }}

with latest_qms as (
    select
        supplier_id,
        argMax(avg_overall_score,        evaluation_period_year) as qms_overall_score,
        argMax(avg_quality_score,        evaluation_period_year) as qms_quality_score,
        argMax(avg_delivery_score,       evaluation_period_year) as qms_delivery_score,
        argMax(avg_responsiveness_score, evaluation_period_year) as qms_responsiveness_score,
        max(evaluation_period_year)                              as last_qms_year
    from {{ ref('fct_qms_supplier_quality') }}
    group by supplier_id
),

latest_proc_eval as (
    select
        supplier_id,
        toFloat64(argMax(overall_score,        evaluation_year * 4 + evaluation_quarter)) as proc_overall_score,
        toFloat64(argMax(quality_score,        evaluation_year * 4 + evaluation_quarter)) as proc_quality_score,
        toFloat64(argMax(delivery_score,       evaluation_year * 4 + evaluation_quarter)) as proc_delivery_score,
        toFloat64(argMax(responsiveness_score, evaluation_year * 4 + evaluation_quarter)) as proc_responsiveness_score,
        toFloat64(argMax(price_score,          evaluation_year * 4 + evaluation_quarter)) as proc_price_score,
        max(evaluation_year)                                                               as last_eval_year
    from {{ ref('fct_procurement_supplier_evaluations') }}
    group by supplier_id
)

select
    s.id_supplier,
    s.supplier_name,
    s.country,
    s.is_active,
    s.nb_purchase_orders,
    s.total_purchase_ht,
    coalesce(q.qms_overall_score, 0)                                as qms_overall_score,
    coalesce(q.qms_quality_score, 0)                                as qms_quality_score,
    coalesce(q.qms_delivery_score, 0)                               as qms_delivery_score,
    coalesce(q.qms_responsiveness_score, 0)                         as qms_responsiveness_score,
    coalesce(q.last_qms_year, 0)                                    as last_qms_evaluation_year,
    coalesce(e.proc_overall_score, 0)                               as proc_overall_score,
    coalesce(e.proc_quality_score, 0)                               as proc_quality_score,
    coalesce(e.proc_delivery_score, 0)                              as proc_delivery_score,
    coalesce(e.proc_responsiveness_score, 0)                        as proc_responsiveness_score,
    coalesce(e.proc_price_score, 0)                                 as proc_price_score,
    coalesce(e.last_eval_year, 0)                                   as last_proc_evaluation_year,
    multiIf(
        q.qms_overall_score is not null and e.proc_overall_score is not null,
            round((q.qms_overall_score + e.proc_overall_score) / 2.0, 2),
        q.qms_overall_score is not null,
            round(q.qms_overall_score, 2),
        e.proc_overall_score is not null,
            round(e.proc_overall_score, 2),
        null
    )                                                               as composite_score,
    multiIf(
        q.qms_overall_score is null and e.proc_overall_score is null,
            'not_evaluated',
        greatest(coalesce(q.qms_overall_score, 0),
                 coalesce(e.proc_overall_score, 0)) >= 80,          'preferred',
        greatest(coalesce(q.qms_overall_score, 0),
                 coalesce(e.proc_overall_score, 0)) >= 60,          'approved',
        'at_risk'
    )                                                               as supplier_status
from {{ ref('dim_suppliers') }} as s
left join latest_qms as q
    on q.supplier_id = s.id_supplier
left join latest_proc_eval as e
    on e.supplier_id = s.id_supplier
