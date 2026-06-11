{{ config(
    materialized='table',
    engine='MergeTree()',
    order_by='(starts_at, employee_id)',
    tags=['bi', 'rh']
) }}

select
    l.id_leave,
    l.employee_id,
    e.first_name,
    e.last_name,
    e.department_name,
    e.position_title,
    l.leave_type_id,
    coalesce(lt.label, l.leave_type_id)                                 as leave_type_name,
    l.status,
    l.starts_at,
    l.ends_at,
    dateDiff('day', l.starts_at, l.ends_at) + 1                       as duration_days,
    if(l.status = 'approved', 1, 0)                                     as is_approved,
    if(l.status = 'rejected', 1, 0)                                     as is_rejected,
    if(l.status = 'pending', 1, 0)                                      as is_pending,
    if(l.starts_at >= today(), 1, 0)                                    as is_future,
    if(l.starts_at <= today() and l.ends_at >= today(), 1, 0)          as is_ongoing,
    toYYYYMM(l.starts_at)                                               as leave_month,
    toYear(l.starts_at)                                                 as leave_year
from {{ ref('fct_leaves') }} as l
left join {{ ref('dim_employees') }} as e
    on e.id_employee = l.employee_id
left join {{ ref('stg_erp__leave_types') }} as lt
    on lt.id_leave_type = l.leave_type_id
