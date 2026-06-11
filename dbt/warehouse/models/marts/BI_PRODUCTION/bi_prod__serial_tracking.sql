{{ config(
    materialized='table',
    engine='MergeTree()',
    order_by='(produced_at, id_serial_number)',
    tags=['bi', 'production']
) }}

select
    sn.id_serial_number,
    sn.serial,
    sn.status,
    sn.work_order_id,
    wo.reference                                                        as work_order_ref,
    wo.pc_model_name,
    wo.pc_model_code,
    wo.planned_at                                                       as wo_planned_at,
    sn.produced_at,
    sn.shipped_at,
    if(sn.produced_at > toDateTime('1970-01-01 00:00:00')
       and sn.shipped_at > toDateTime('1970-01-01 00:00:00'),
       dateDiff('day', sn.produced_at, sn.shipped_at),
       null)                                                            as days_produced_to_shipped,
    if(sn.shipped_at > toDateTime('1970-01-01 00:00:00'), 1, 0)        as is_shipped,
    if(sn.produced_at > toDateTime('1970-01-01 00:00:00'), 1, 0)       as is_produced,
    if(sn.produced_at > toDateTime('1970-01-01 00:00:00')
       and sn.shipped_at = toDateTime('1970-01-01 00:00:00'), 1, 0)    as is_in_stock,
    multiIf(
        sn.status = 'shipped',                  'shipped',
        sn.status = 'in_repair',                'in_repair',
        sn.produced_at > toDateTime('1970-01-01 00:00:00'), 'produced',
        'pending'
    )                                                                   as lifecycle_status
from {{ ref('stg_erp__serial_numbers') }} as sn
left join {{ ref('fct_work_orders') }} as wo
    on wo.id_work_order = sn.work_order_id
