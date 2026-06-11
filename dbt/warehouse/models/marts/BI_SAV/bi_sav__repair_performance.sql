{{ config(
    materialized='table',
    engine='MergeTree()',
    order_by='(received_at, id_repair_order)',
    tags=['bi', 'sav']
) }}

select
    ro.id_repair_order,
    ro.status,
    ro.description,
    ro.serial_number,
    sn.work_order_id                                                    as origin_work_order_id,
    wo.pc_model_name,
    wo.pc_model_code,
    ro.received_at,
    ro.resolved_at,
    ro.nb_parts_used,
    ro.total_parts_qty,
    ro.resolution_days,
    ro.is_resolved,
    ro.is_stalled,
    multiIf(
        ro.is_resolved = 0
            and ro.received_at > toDateTime('1970-01-01 00:00:00'), 'open',
        ro.resolution_days <= 3,                                        'quick_0_3d',
        ro.resolution_days <= 7,                                        'standard_4_7d',
        ro.resolution_days <= 14,                                       'slow_8_14d',
        'critical_14d_plus'
    )                                                                   as resolution_bucket,
    toYYYYMM(toDate(ro.received_at))                                    as repair_month
from {{ ref('fct_repair_orders') }} as ro
left join {{ ref('stg_erp__serial_numbers') }} as sn
    on sn.serial = ro.serial_number
left join {{ ref('fct_work_orders') }} as wo
    on wo.id_work_order = sn.work_order_id
