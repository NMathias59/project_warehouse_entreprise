{{ config(tags=['staging', 'sirh']) }}

with source as (

    select * from {{ source('sirh', 'departments') }}
    where id is not null

),

deduped as (

    select
        id,
        argMax(code,                  _airbyte_extracted_at) as code,
        argMax(name,                  _airbyte_extracted_at) as name,
        argMax(parent_department_id,  _airbyte_extracted_at) as parent_department_id,
        argMax(manager_id,            _airbyte_extracted_at) as manager_id,
        argMax(cost_center_code,      _airbyte_extracted_at) as cost_center_code,
        argMax(is_active,             _airbyte_extracted_at) as is_active,
        argMax(created_at,            _airbyte_extracted_at) as created_at,
        argMax(updated_at,            _airbyte_extracted_at) as updated_at,
        max(_airbyte_extracted_at)                           as latest_extracted_at
    from source
    group by id

)

select
    cast(id                                   as varchar)   as id_department,
    cast(coalesce(code, '')                   as varchar)   as code,
    cast(coalesce(name, '')                   as varchar)   as name,
    cast(coalesce(parent_department_id, '')   as varchar)   as parent_department_id,
    cast(coalesce(manager_id, '')             as varchar)   as manager_id,
    cast(coalesce(cost_center_code, '')       as varchar)   as cost_center_code,
    cast(coalesce(is_active, false)           as boolean)   as is_active,
    cast(created_at                           as timestamp) as created_at,
    toDateTimeOrNull(toString(updated_at))                  as updated_at,
    cast(latest_extracted_at                  as timestamp) as _etl_loaded_at
from deduped
