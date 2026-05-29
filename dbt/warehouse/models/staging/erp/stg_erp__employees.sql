{{ config(tags=['staging', 'erp']) }}

select
    cast(id as varchar)                  as id_employee,
    cast(email as varchar)               as email,
    -- null-safe date: avoid inserting NULLs into non-nullable Date columns in ClickHouse
    coalesce(toDateOrNull(left_at), toDate('1970-01-01')) as left_at,
    cast(hired_at as date)               as hired_at,
    cast(is_active as boolean)           as is_active,
    cast(last_name as varchar)           as last_name,
    cast(first_name as varchar)          as first_name,
    cast(created_at as timestamp)        as created_at,
    cast(deleted_at as timestamp)        as deleted_at,
    cast(position_id as varchar)         as position_id,
    cast(department_id as varchar)       as department_id
from {{ source('erp', 'employees') }}
where id is not null
