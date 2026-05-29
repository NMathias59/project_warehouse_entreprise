{{ config(tags=['staging', 'erp']) }}

select
	cast(id as varchar)              as id_tag,
	cast(name as varchar)            as name,
	cast(slug as varchar)            as slug,
	cast(created_at as timestamp)    as created_at
from {{ source('erp', 'tags') }}
where id is not null
