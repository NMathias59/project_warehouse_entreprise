{{ config(tags=['staging', 'erp']) }}

select
	cast(id as varchar)                  as id_repair_order_line,
	cast(notes as varchar)               as notes,
	cast(action as varchar)              as action,
	cast(quantity as bigint)             as quantity,
	cast(component_id as varchar)        as component_id,
	cast(repair_order_id as varchar)     as repair_order_id
from {{ source('erp', 'repair_order_lines') }}
where id is not null
