{{ config(tags=['staging', 'erp']) }}

select
	cast(id as varchar)              as id_warehouse_location,
	cast(coalesce(bin, '') as varchar)   as bin,
	cast(coalesce(code, '') as varchar)  as code,
	cast(rack as varchar)            as rack,
	cast(aisle as varchar)           as aisle,
	cast(level as varchar)           as level,
	cast(created_at as timestamp)    as created_at,
	cast(warehouse_id as varchar)    as warehouse_id
from {{ source('erp', 'warehouse_locations') }}
where id is not null
