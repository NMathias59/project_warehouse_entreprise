{{ config(tags=['staging', 'erp']) }}

select
	cast(id as varchar)              as id_product_tag,
	cast(tag_id as varchar)          as tag_id,
	cast(product_id as varchar)      as product_id
from {{ source('erp', 'product_tags') }}
where id is not null
