{{ config(tags=['staging', 'erp']) }}

with source as (
    select * from {{ source('erp', 'timesheet_lines') }}
)

select
    cast(id as varchar)                as id_timesheet_line,
    cast(timesheet_id as varchar)      as timesheet_id,
    cast(day as date)                  as day,
    cast(type as varchar)              as type,
    cast(hours as decimal(10,2))       as hours,
    cast(nullIf(notes, '') as Nullable(String)) as notes,
    cast(_ab_cdc_updated_at as varchar) as updated_at
from source
where id is not null
