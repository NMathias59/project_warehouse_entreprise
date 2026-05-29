{{ config(tags=['staging', 'erp']) }}

select
	cast(id as varchar)              as id_stock_alert,
	cast(max_qty as bigint)          as max_qty,
	cast(min_qty as bigint)          as min_qty,
	cast(is_active as boolean)       as is_active,
	cast(created_at as timestamp)    as created_at,
	cast(component_id as varchar)    as component_id,
	cast(last_alert_at as timestamp) as last_alert_at
from {{ source('erp', 'stock_alerts') }}
where id is not null
