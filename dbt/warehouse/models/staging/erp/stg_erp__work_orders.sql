{{ config(tags=['staging', 'erp']) }}

select
	cast(id as varchar)                  as id_work_order,
	cast(status as varchar)              as status,
	cast(quantity as bigint)             as quantity,
	cast(reference as varchar)           as reference,
 	cast(coalesce(created_at, toDateTime('1970-01-01 00:00:00')) as timestamp)        as created_at,
 	cast(coalesce(deleted_at, toDateTime('1970-01-01 00:00:00')) as timestamp)        as deleted_at,
	cast(planned_at as date)             as planned_at,
 	cast(coalesce(started_at, toDateTime('1970-01-01 00:00:00')) as timestamp)        as started_at,
 	cast(coalesce(updated_at, toDateTime('1970-01-01 00:00:00')) as timestamp)        as updated_at,
	cast(pc_model_id as varchar)         as pc_model_id,
 	cast(coalesce(completed_at, toDateTime('1970-01-01 00:00:00')) as timestamp)      as completed_at
from {{ source('erp', 'work_orders') }}
where id is not null
