{{ config(
    materialized='table',
    engine='MergeTree()',
    order_by='tuple()',
    tags=['bi', 'production']
) }}

with defects_by_wo as (

    select
        work_order_id,
        count(id_defect_report)                             as nb_defect_reports,
        countIf(resolved_at > toDateTime('1970-01-01 00:00:00')) as nb_resolved,
        countIf(resolved_at = toDateTime('1970-01-01 00:00:00')) as nb_unresolved
    from {{ ref('stg_erp__defect_reports') }}
    group by work_order_id

)

select
    qc.id_quality_check,
    qc.work_order_id,
    wo.reference                                                        as work_order_ref,
    wo.pc_model_name,
    wo.pc_model_code,
    wo.status                                                           as work_order_status,
    qc.operator,
    qc.overall_result,
    qc.check_date,
    qc.nb_check_items,
    qc.nb_passed,
    qc.nb_failed,
    qc.pass_rate_pct,
    qc.is_passed,
    coalesce(d.nb_defect_reports, 0)                                    as nb_defect_reports,
    coalesce(d.nb_resolved, 0)                                          as nb_defects_resolved,
    coalesce(d.nb_unresolved, 0)                                        as nb_defects_unresolved,
    if(coalesce(d.nb_defect_reports, 0) > 0,
       round(coalesce(d.nb_resolved, 0) * 100.0 / d.nb_defect_reports, 2),
       null)                                                            as defect_resolution_rate_pct
from {{ ref('fct_quality_checks') }} as qc
left join {{ ref('fct_work_orders') }} as wo
    on wo.id_work_order = qc.work_order_id
left join defects_by_wo as d
    on d.work_order_id = qc.work_order_id
