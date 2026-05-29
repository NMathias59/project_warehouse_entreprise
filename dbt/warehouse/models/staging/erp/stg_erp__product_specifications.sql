{{ config(tags=['staging', 'erp']) }}

select
	cast(id as varchar)              as id_product_specification,
	cast(key as varchar)             as key,
	cast(unit as varchar)            as unit,
	cast(value as varchar)           as value,
	cast(extras as varchar)          as extras,
	cast(position as bigint)         as position,
	cast(created_at as timestamp)    as created_at,
	cast(product_id as varchar)      as product_id
from {{ source('erp', 'product_specifications') }}
where id is not null
