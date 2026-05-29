{{ config(tags=['staging', 'erp']) }}

select
	cast(id as varchar)              as id_supplier,
	cast(code as varchar)            as code,
	cast(name as varchar)            as name,
	cast(country as varchar)         as country,
	cast(website as varchar)         as website,
	cast(is_active as boolean)       as is_active,
	cast(created_at as timestamp)    as created_at,
	cast(deleted_at as timestamp)    as deleted_at,
	cast(updated_at as timestamp)    as updated_at
from {{ source('erp', 'suppliers') }}
where id is not null
