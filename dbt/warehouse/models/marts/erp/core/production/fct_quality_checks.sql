{{ config(
    materialized='table',
    engine='MergeTree()',
    order_by='(checked_at, id_quality_check)',
    tags=['marts', 'erp', 'production']
) }}

select
    qc.id_quality_check,
    qc.work_order_id,
    qc.operator,
    qc.result                                                           as overall_result,
    coalesce(qc.notes, '')                                                  as notes,
    qc.checked_at,
    toDate(qc.checked_at)                                               as check_date,
    count(qi.id_quality_check_item)                                     as nb_check_items,
    countIf(qi.result = 'pass')                                         as nb_passed,
    countIf(qi.result = 'fail')                                         as nb_failed,
    if(count(qi.id_quality_check_item) > 0,
       round(countIf(qi.result = 'pass') * 100.0
             / count(qi.id_quality_check_item), 2),
       null)                                                            as pass_rate_pct,
    if(qc.result = 'pass', 1, 0)                                        as is_passed
from {{ ref('stg_erp__quality_checks') }} as qc
left join {{ ref('stg_erp__quality_check_items') }} as qi
    on qi.quality_check_id = qc.id_quality_check
group by
    qc.id_quality_check, qc.work_order_id, qc.operator,
    qc.result, coalesce(qc.notes, ''), qc.checked_at
