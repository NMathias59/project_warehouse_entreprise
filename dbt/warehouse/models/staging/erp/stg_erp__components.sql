{{ config(tags=['staging', 'erp']) }}

SELECT cast(id as varchar)           as id_components,
       cast(name as varchar)         as name,
       cast(unit as varchar)         as unit,
       cast(is_active as boolean)     as is_active,
       cast(max_stock as int)        as max_stock,
       cast(min_stock as int)        as min_stock,
       cast(created_at as timestamp) as created_at,
       cast(updated_at as timestamp) as updated_at,
       cast(category_id as varchar)  as category_id,
       cast(sku_internal as varchar) as sku_internal
FROM {{ source('erp', 'components') }}
WHERE id IS NOT NULL