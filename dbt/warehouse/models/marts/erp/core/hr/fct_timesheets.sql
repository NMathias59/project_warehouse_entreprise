{{
    config(
        materialized='incremental',
        unique_key='id_timesheet_line',
        incremental_strategy='append',
        tags=['core', 'erp', 'fct', 'hr'],
        pre_hook=[
            "{{ clickhouse_delete_existing_rows(ref('stg_erp__timesheets'), 'id_timesheet', 'id_timesheet', 'week_start', 30) }}"
        ]
    )
}}

with ts as (
    select * from {{ ref('stg_erp__timesheets') }}
),
tsl as (
    select * from {{ ref('stg_erp__timesheet_lines') }}
),
joined as (
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
),
deduped as (
    select
        *,
        row_number() over (partition by id_timesheet_line order by week_start desc) as rn
    from joined
)
select
    id_timesheet,
    employee_id,
    week_start,
    status,
    total_hours,
    id_timesheet_line,
    day,
    type,
    hours,
    notes
from deduped
where rn = 1

{% if is_incremental() %}
and week_start > (select coalesce(max(week_start), toDate('1970-01-01')) from {{ this }})
{% endif %}