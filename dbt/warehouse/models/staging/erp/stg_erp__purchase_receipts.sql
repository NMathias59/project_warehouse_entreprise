{{ config(tags=['staging', 'erp']) }}

select
	cast(id as varchar)                  as id_purchase_receipt,
	cast(reference as varchar)           as reference,
	cast(created_at as timestamp)        as created_at,
	cast(received_at as timestamp)       as received_at,
	cast(purchase_order_id as varchar)   as purchase_order_id
from {{ source('erp', 'purchase_receipts') }}
where id is not null
