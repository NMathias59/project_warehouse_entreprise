{{
    config(
        materialized='incremental',
        unique_key='id_timesheet',
        incremental_strategy='append',
        tags=['core', 'erp', 'fct', 'hr']
    )
}}

with ts as (
    select * from {{ ref('stg_erp__timesheets') }}
),
tsl as (
    select * from {{ ref('stg_erp__timesheet_lines') }}
)

select
    ts.id_timesheet,
    ts.employee_id,
    ts.week_start,
    ts.status,
    ts.total_hours,
    tsl.id_timesheet_line,
    tsl.day,
    tsl.type,
    tsl.hours,
    cast(ifNull(tsl.notes, '') as Nullable(String)) as notes
from ts
left join tsl on ts.id_timesheet = tsl.timesheet_id

{% if is_incremental() %}
where ts.created_at > (select coalesce(max(week_start), '1970-01-01') from {{ this }})
{% endif %}