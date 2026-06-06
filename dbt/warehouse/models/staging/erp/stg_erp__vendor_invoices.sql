{{ config(tags=['staging', 'erp']) }}

select
	cast(id as varchar)                  as id_vendor_invoice,
	cast(due_at as date)                 as due_at,
	cast(status as varchar)              as status,
	if(paid_at IS NULL, NULL, cast(paid_at as timestamp)) as paid_at,
	cast(currency as varchar)            as currency,
	cast(total_ht as decimal(38,9))      as total_ht,
	cast(issued_at as date)              as issued_at,
	cast(reference as varchar)           as reference,
	cast(total_ttc as decimal(38,9))     as total_ttc,
	cast(created_at as timestamp)        as created_at,
	cast(supplier_id as varchar)         as supplier_id,
	cast(purchase_order_id as varchar)   as purchase_order_id
from {{ source('erp', 'vendor_invoices') }}
where id is not null
