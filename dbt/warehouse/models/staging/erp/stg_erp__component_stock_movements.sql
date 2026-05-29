{{ config(tags=['staging', 'erp']) }}

SELECT cast(id as varchar)           as id_component_stock_movement,
       cast(type as varchar)         as type,
       cast(moved_at as timestamp)   as moved_at,
       cast(coalesce(quantity, 0) as int)         as quantity,
       cast(coalesce(reference, '') as varchar)    as reference,
       cast(coalesce(location_id, '') as varchar)  as location_id,
       cast(component_id as varchar) as component_id
FROM {{ source('erp', 'component_stock_movements') }}
WHERE id IS NOT NULL