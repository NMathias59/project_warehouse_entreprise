{{ config(tags=['staging', 'erp']) }}

select
	cast(id as varchar)              as id_purchase_receipt_line,
	cast(quantity as bigint)         as quantity,
	cast(condition as varchar)       as condition,
	cast(created_at as timestamp)    as created_at,
	cast(receipt_id as varchar)      as receipt_id,
	cast(component_id as varchar)    as component_id
from {{ source('erp', 'purchase_receipt_lines') }}
where id is not null
