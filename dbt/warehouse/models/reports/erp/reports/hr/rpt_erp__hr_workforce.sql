{{ config(
    materialized='table',
    tags=['reports', 'erp', 'hr']
) }}

with employees as (

    select
        id_employee,
        first_name,
        last_name,
        email,
        department_name,
        position_title,
        contract_type,
        salary,
        currency,
        contract_start,
        contract_end,
        contract_active,
        hired_at,
        left_at
    from {{ ref('dim_employees') }}

),

leave_summary as (

    select
        employee_id,
        countIf(status = 'approved')                             as approved_leaves_count,
        countIf(status = 'pending')                              as pending_leaves_count,
        sumIf(dateDiff('day', starts_at, ends_at), status = 'approved') as total_approved_leave_days
    from {{ ref('fct_leaves') }}
    group by employee_id

),

timesheet_summary as (

    select
        employee_id,
        count(distinct id_timesheet)     as timesheets_count,
        sum(hours)                       as total_hours_worked,
        max(week_start)                  as last_timesheet_week
    from {{ ref('fct_timesheets') }}
    group by employee_id

),

final as (

    select
        e.id_employee,
        e.first_name,
        e.last_name,
        e.email,
        e.department_name,
        e.position_title,
        e.contract_type,
        e.salary,
        e.currency,
        e.contract_active,
        e.hired_at,
        e.left_at,
        if(e.left_at is null, 1, 0)                             as is_active,
        coalesce(l.approved_leaves_count, 0)                    as approved_leaves_count,
        coalesce(l.pending_leaves_count, 0)                     as pending_leaves_count,
        coalesce(l.total_approved_leave_days, 0)                as total_approved_leave_days,
        coalesce(ts.timesheets_count, 0)                        as timesheets_count,
        coalesce(ts.total_hours_worked, 0)                      as total_hours_worked,
        ts.last_timesheet_week
    from employees e
    left join leave_summary l      on e.id_employee = l.employee_id
    left join timesheet_summary ts on e.id_employee = ts.employee_id

)

select * from final
