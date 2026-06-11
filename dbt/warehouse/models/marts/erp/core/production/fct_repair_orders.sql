{{ config(
    materialized='table',
    engine='MergeTree()',
    order_by='(received_at, id_repair_order)',
    tags=['marts', 'erp', 'production']
) }}

select
    ro.id_repair_order,
    ro.status,
    ro.description,
    ro.serial_number,
    ro.received_at,
    ro.resolved_at,
    ro.created_at,
    count(rol.id_repair_order_line)                                     as nb_parts_used,
    coalesce(sum(rol.quantity), 0)                                      as total_parts_qty,
    groupArray(rol.component_id)                                        as components_used,
    if(ro.resolved_at > toDateTime('1970-01-01 00:00:00')
       and ro.received_at > toDateTime('1970-01-01 00:00:00'),
       dateDiff('day', ro.received_at, ro.resolved_at),
       null)                                                            as resolution_days,
    if(ro.status = 'resolved', 1, 0)                                    as is_resolved,
    if(ro.received_at > toDateTime('1970-01-01 00:00:00')
       and ro.status != 'resolved'
       and dateDiff('day', ro.received_at, now()) > 7, 1, 0)           as is_stalled
from {{ ref('stg_erp__repair_orders') }} as ro
left join {{ ref('stg_erp__repair_order_lines') }} as rol
    on rol.repair_order_id = ro.id_repair_order
where ro.received_at > toDateTime('1970-01-01 00:00:00')
group by
    ro.id_repair_order, ro.status, ro.description, ro.serial_number,
    ro.received_at, ro.resolved_at, ro.created_at
