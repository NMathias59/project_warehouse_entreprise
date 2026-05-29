{{ config(tags=['staging', 'erp']) }}

select
	cast(id as varchar)                  as id_quality_check_item,
 	cast(coalesce(notes, '') as varchar)               as notes,
 	cast(coalesce(result, '') as varchar)              as result,
 	cast(coalesce(check_name, '') as varchar)          as check_name,
	cast(checked_at as timestamp)        as checked_at,
 	cast(coalesce(actual_value, '') as varchar)        as actual_value,
 	cast(coalesce(expected_value, '') as varchar)      as expected_value,
	cast(quality_check_id as varchar)    as quality_check_id
from {{ source('erp', 'quality_check_items') }}
where id is not null
