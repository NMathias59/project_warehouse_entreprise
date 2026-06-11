{{ config(
    materialized='table',
    engine='MergeTree()',
    order_by='tuple()',
    tags=['bi', 'production']
) }}

with defects_by_wo as (

    select
        work_order_id,
        count(id_defect_report)                                          as nb_defect_reports,
        countIf(isNotNull(resolved_at))                                  as nb_resolved
    from {{ ref('stg_erp__defect_reports') }}
    group by work_order_id

)

select
    qc.operator,
    toYYYYMM(qc.check_date)                                              as check_month,
    count(qc.id_quality_check)                                           as total_checks,
    countIf(qc.is_passed = 1)                                            as checks_passed,
    countIf(qc.is_passed = 0)                                            as checks_failed,
    if(count(qc.id_quality_check) > 0,
       round(countIf(qc.is_passed = 1) * 100.0
             / count(qc.id_quality_check), 2),
       0)                                                                as pass_rate_pct,
    round(avg(qc.pass_rate_pct), 2)                                      as avg_item_pass_rate_pct,
    sum(qc.nb_check_items)                                               as total_items_checked,
    sum(qc.nb_failed)                                                    as total_items_failed,
    coalesce(sum(d.nb_defect_reports), 0)                                as total_defect_reports,
    coalesce(sum(d.nb_resolved), 0)                                      as defects_resolved,
    if(coalesce(sum(d.nb_defect_reports), 0) > 0,
       round(coalesce(sum(d.nb_resolved), 0) * 100.0
             / nullIf(sum(d.nb_defect_reports), 0), 2),
       null)                                                             as defect_resolution_rate_pct
from {{ ref('fct_quality_checks') }} as qc
left join defects_by_wo as d
    on d.work_order_id = qc.work_order_id
where qc.operator != ''
group by qc.operator, toYYYYMM(qc.check_date)
