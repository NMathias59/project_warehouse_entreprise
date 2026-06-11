{{ config(tags=['staging', 'erp']) }}

select
	cast(id as varchar)              as id_quality_check,
	cast(coalesce(notes, '') as varchar) as notes,
	cast(result as varchar)          as result,
	cast(operator as varchar)        as operator,
	cast(checked_at as timestamp)    as checked_at,
	cast(work_order_id as varchar)   as work_order_id
from {{ source('erp', 'quality_checks') }}
where id is not null
