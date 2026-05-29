{{ config(tags=['staging', 'erp']) }}

select
	cast(id as varchar)                  as id_employee_contract,
	cast(type as varchar)                as type,
	cast(salary as decimal(38,9))        as salary,
	cast(currency as varchar)            as currency,
	cast(is_active as boolean)           as is_active,
	cast(reference as varchar)           as reference,
	   -- NULL-safe dates: coalesce to sentinel values so comparisons work in downstream logic
		cast(coalesce(ends_at, toDate('2099-12-31')) as date)                as ends_at,
					cast(coalesce(starts_at, toDate('1970-01-01')) as date)              as starts_at,
	cast(created_at as timestamp)        as created_at,
	cast(employee_id as varchar)         as employee_id
from {{ source('erp', 'employee_contracts') }}
where id is not null
