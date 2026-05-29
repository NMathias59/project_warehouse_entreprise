{{ config(tags=['staging', 'erp']) }}

select
	cast(id as varchar)                  as id_warranty,
	cast(type as varchar)                as type,
	cast(created_at as timestamp)        as created_at,
	cast(supplier_id as varchar)         as supplier_id,
	cast(component_id as varchar)        as component_id,
	cast(duration_months as bigint)      as duration_months
from {{ source('erp', 'warranties') }}
where id is not null
