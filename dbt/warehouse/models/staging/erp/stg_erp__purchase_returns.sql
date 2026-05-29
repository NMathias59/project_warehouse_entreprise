{{ config(tags=['staging', 'erp']) }}

select
	cast(id as varchar)                  as id_purchase_return,
	cast(reason as varchar)              as reason,
	cast(status as varchar)              as status,
	cast(quantity as bigint)             as quantity,
	cast(reference as varchar)           as reference,
	cast(created_at as timestamp)        as created_at,
	cast(resolved_at as timestamp)       as resolved_at,
	cast(returned_at as timestamp)       as returned_at,
	cast(supplier_id as varchar)         as supplier_id,
	cast(component_id as varchar)        as component_id,
	cast(purchase_order_id as varchar)   as purchase_order_id
from {{ source('erp', 'purchase_returns') }}
where id is not null
