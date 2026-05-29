{{ config(tags=['staging', 'erp']) }}

select
	cast(id as varchar)              as id_work_order_step,
	cast(seq as bigint)              as seq,
	cast(name as varchar)            as name,
	cast(status as varchar)          as status,
	cast(created_at as timestamp)    as created_at,
	cast(started_at as timestamp)    as started_at,
	cast(assigned_to as varchar)     as assigned_to,
	cast(description as varchar)     as description,
	cast(completed_at as timestamp)  as completed_at,
	cast(work_order_id as varchar)   as work_order_id
from {{ source('erp', 'work_order_steps') }}
where id is not null
