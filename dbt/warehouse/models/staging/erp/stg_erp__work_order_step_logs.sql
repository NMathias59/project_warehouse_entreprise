{{ config(tags=['staging', 'erp']) }}

select
	cast(id as varchar)                  as id_work_order_step_log,
	-- make notes null-safe to avoid ClickHouse casting errors
	cast(coalesce(notes, '') as varchar)               as notes,
	cast(action as varchar)              as action,
	cast(step_id as varchar)             as step_id,
	-- null-safe timestamp: prefer toDateTimeOrNull then fallback to sentinel
	coalesce(toDateTimeOrNull(created_at), toDateTime('1970-01-01 00:00:00')) as created_at,
	cast(employee_id as varchar)         as employee_id,
	cast(duration_minutes as bigint)     as duration_minutes
from {{ source('erp', 'work_order_step_logs') }}
where id is not null
