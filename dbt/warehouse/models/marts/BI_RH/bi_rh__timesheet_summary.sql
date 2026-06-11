{{ config(
    materialized='table',
    engine='MergeTree()',
    order_by='(week_start, employee_id)',
    tags=['bi', 'rh']
) }}

select
    ts.employee_id,
    e.first_name,
    e.last_name,
    e.department_name,
    e.position_title,
    ts.week_start,
    ts.status                                                           as timesheet_status,
    count(distinct ts.id_timesheet_line)                                as nb_entries,
    round(sum(ts.hours), 2)                                             as total_hours,
    round(sumIf(ts.hours, ts.type = 'regular'), 2)                     as regular_hours,
    round(sumIf(ts.hours, ts.type = 'overtime'), 2)                    as overtime_hours,
    round(sumIf(ts.hours, ts.type = 'remote'), 2)                      as remote_hours,
    round(sumIf(ts.hours, ts.type = 'training'), 2)                    as training_hours,
    if(sum(ts.hours) > 0,
       round(sumIf(ts.hours, ts.type = 'overtime') * 100.0
             / sum(ts.hours), 2),
       0)                                                               as overtime_rate_pct,
    if(sum(ts.hours) > 0,
       round(sumIf(ts.hours, ts.type = 'remote') * 100.0
             / sum(ts.hours), 2),
       0)                                                               as remote_rate_pct
from {{ ref('fct_timesheets') }} as ts
left join {{ ref('dim_employees') }} as e
    on e.id_employee = ts.employee_id
group by
    ts.employee_id, e.first_name, e.last_name,
    e.department_name, e.position_title,
    ts.week_start, ts.status
