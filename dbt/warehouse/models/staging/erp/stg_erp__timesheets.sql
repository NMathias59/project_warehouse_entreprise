{{ config(tags=['staging', 'erp']) }}

with source as (
    select * from {{ source('erp', 'timesheets') }}
)

select
    cast(id as varchar)                as id_timesheet,
    cast(employee_id as varchar)       as employee_id,
    cast(week_start as date)           as week_start,
    cast(status as varchar)            as status,
    cast(total_hours as decimal(10,2)) as total_hours,
    cast(created_at as timestamp)      as created_at
from source
where id is not null
