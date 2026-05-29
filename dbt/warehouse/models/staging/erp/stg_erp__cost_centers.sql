{{ config(tags=['staging', 'erp']) }}

select
    cast(id as varchar)           as id_cost_center,
    cast(code as varchar)            as code,
    cast(name as varchar)            as name,
    cast(is_active as boolean)       as is_active,
    cast(created_at as timestamp)    as created_at
from {{ source('erp', 'cost_centers') }}
where id is not null