{{ config(tags=['staging', 'erp']) }}

select
	cast(id as varchar)              as id_repair_order,
	cast(status as varchar)          as status,
	cast(created_at as timestamp)    as created_at,
 	cast(coalesce(description, '') as varchar)     as description,
 	cast(coalesce(received_at, toDateTime('1970-01-01 00:00:00')) as timestamp)   as received_at,
 	cast(coalesce(resolved_at, toDateTime('1970-01-01 00:00:00')) as timestamp)   as resolved_at,
 	cast(coalesce(serial_number, '') as varchar)   as serial_number
from {{ source('erp', 'repair_orders') }}
where id is not null
