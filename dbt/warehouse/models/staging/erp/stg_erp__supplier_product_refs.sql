{{ config(tags=['staging', 'erp']) }}

select
	cast(id as varchar)                  as id_supplier_product_ref,
	cast(ean13 as varchar)               as ean13,
	cast(created_at as timestamp)        as created_at,
	cast(unit_price as decimal(38,9))    as unit_price,
	cast(supplier_id as varchar)         as supplier_id,
	cast(component_id as varchar)        as component_id,
	cast(supplier_sku as varchar)        as supplier_sku,
	cast(lead_time_days as bigint)       as lead_time_days
from {{ source('erp', 'supplier_product_refs') }}
where id is not null
