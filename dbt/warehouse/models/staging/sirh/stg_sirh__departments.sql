{{ config(tags=['staging', 'sirh']) }}

with base as (

    select * from {{ ref('base_sirh__departments') }}

)

select
    cast(id                                   as varchar)   as id_department,
    cast(coalesce(code, '')                   as varchar)   as code,
    cast(coalesce(name, '')                   as varchar)   as name,
    cast(coalesce(parent_department_id, '')   as varchar)   as parent_department_id,
    cast(coalesce(manager_id, '')             as varchar)   as manager_id,
    cast(''                                   as varchar)   as cost_center_code,
    cast(false                                as boolean)   as is_active,
    cast(created_at                           as timestamp) as created_at,
    cast(null as Nullable(DateTime64(3)))                   as updated_at,
    cast(latest_extracted_at                as timestamp) as _etl_loaded_at
from base
