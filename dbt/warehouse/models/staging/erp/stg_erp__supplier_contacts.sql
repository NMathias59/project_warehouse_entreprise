{{ config(tags=['staging', 'erp']) }}

select
	cast(id as varchar)              as id_supplier_contact,
	cast(role as varchar)            as role,
	cast(email as varchar)           as email,
	cast(phone as varchar)           as phone,
	cast(last_name as varchar)       as last_name,
	cast(created_at as timestamp)    as created_at,
	cast(first_name as varchar)      as first_name,
	cast(supplier_id as varchar)     as supplier_id
from {{ source('erp', 'supplier_contacts') }}
where id is not null
