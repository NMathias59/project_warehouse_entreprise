{{ config(tags=['staging', 'erp']) }}

with source as (
    select * from {{ source('erp', 'leaves') }}
)

select
    cast(id as varchar)                as id_leave,
    cast(employee_id as varchar)       as employee_id,
    cast(type as varchar)              as type,
    cast(status as varchar)            as status,
    cast(starts_at as date)            as starts_at,
    cast(ends_at as date)              as ends_at,
    cast(coalesce(approved_by, '') as varchar)       as approved_by,
    cast(created_at as timestamp)      as created_at,
    cast(leave_type_id as varchar)     as leave_type_id,
    cast(_ab_cdc_updated_at as varchar) as updated_at
from source
where id is not null
