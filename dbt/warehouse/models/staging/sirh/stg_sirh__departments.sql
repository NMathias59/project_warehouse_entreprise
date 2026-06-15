{{ config(tags=['staging', 'sirh']) }}

with source as (

    select * from {{ source('sirh', 'departments') }}
    where id is not null

),

deduped as (

    select
        id,
        argMax(code,            _airbyte_extracted_at) as code,
        argMax(name,            _airbyte_extracted_at) as name,
        argMax(parent_id,       _airbyte_extracted_at) as parent_department_id,
        argMax(manager_erp_ref, _airbyte_extracted_at) as manager_id,
        argMax(created_at,      _airbyte_extracted_at) as created_at,
        max(_airbyte_extracted_at)                     as latest_extracted_at
    from source
    group by id

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
    cast(latest_extracted_at                  as timestamp) as _etl_loaded_at
from deduped
