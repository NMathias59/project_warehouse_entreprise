{{ config(tags=['staging', 'erp']) }}

select
	cast(id as varchar)              as id_position,
	cast(title as varchar)           as title,
	cast(created_at as timestamp)    as created_at,
	cast(department_id as varchar)   as department_id
from {{ source('erp', 'positions') }}
where id is not null
