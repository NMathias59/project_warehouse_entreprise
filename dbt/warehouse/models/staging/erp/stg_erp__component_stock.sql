{{ config(tags=['staging', 'erp']) }}

select cast(id as varchar)           as id_component_stock,
       cast(quantity as int)         as quantity,
       cast(updated_at as timestamp) as updated_at,
       cast(location_id as varchar)  as location_id,
       cast(component_id as varchar) as component_id
from {{ source('erp', 'component_stock') }}
where id is not null