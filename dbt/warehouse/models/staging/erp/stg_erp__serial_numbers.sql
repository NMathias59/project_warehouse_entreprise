{{ config(tags=['staging', 'erp']) }}

select
	cast(id as varchar)              as id_serial_number,
	cast(serial as varchar)          as serial,
	cast(status as varchar)          as status,
 	cast(coalesce(shipped_at, toDateTime('1970-01-01 00:00:00')) as timestamp)    as shipped_at,
 	cast(coalesce(produced_at, toDateTime('1970-01-01 00:00:00')) as timestamp)   as produced_at,
	cast(work_order_id as varchar)   as work_order_id
from {{ source('erp', 'serial_numbers') }}
where id is not null
