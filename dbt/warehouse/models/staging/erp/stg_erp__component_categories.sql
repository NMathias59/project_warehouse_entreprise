{{ config(tags=['staging', 'erp']) }}

SELECT cast(id as varchar)           as id_component_category,
       cast(code as varchar)         as code,
       cast(name as varchar)         as name,
       cast(parent_id as varchar)    as parent_id,
       cast(created_at as timestamp) as created_at
FROM {{ source('erp', 'component_categories') }}
WHERE id IS NOT NULL
