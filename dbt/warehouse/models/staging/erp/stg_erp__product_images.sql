{{ config(tags=['staging', 'erp']) }}

select
	cast(id as varchar)              as id_product_image,
	cast(alt as varchar)             as alt,
	cast(url as varchar)             as url,
	cast(position as bigint)         as position,
	cast(created_at as timestamp)    as created_at,
	cast(is_primary as boolean)      as is_primary,
	cast(product_id as varchar)      as product_id
from {{ source('erp', 'product_images') }}
where id is not null
