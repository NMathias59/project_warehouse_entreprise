{{ config(tags=['staging', 'erp']) }}

select
	cast(id as varchar)                  as id_vendor_invoice_line,
	cast(quantity as bigint)             as quantity,
	cast(total_ht as decimal(38,9))      as total_ht,
	cast(unit_price as decimal(38,9))    as unit_price,
	cast(description as varchar)         as description,
	cast(component_id as varchar)        as component_id,
	cast(vendor_invoice_id as varchar)   as vendor_invoice_id
from {{ source('erp', 'vendor_invoice_lines') }}
where id is not null
