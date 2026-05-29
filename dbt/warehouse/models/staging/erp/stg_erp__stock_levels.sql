{{ config(tags=['staging', 'erp']) }}

select
	cast(id as varchar)              as id_stock_level,
	cast(quantity as bigint)         as quantity,
	cast(reserved as bigint)         as reserved,
	cast(product_id as varchar)      as product_id,
	cast(updated_at as timestamp)    as updated_at,
	cast(warehouse_id as varchar)    as warehouse_id
from {{ source('erp', 'stock_levels') }}
where id is not null
