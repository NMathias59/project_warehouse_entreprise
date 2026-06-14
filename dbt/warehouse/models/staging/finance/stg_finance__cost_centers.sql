{{ config(tags=['staging', 'finance']) }}

with source as (

    select * from {{ source('finance', 'cost_centers') }}
    where id is not null

),

deduped as (

    select
        id,
        argMax(code,           _airbyte_extracted_at) as code,
        argMax(label,          _airbyte_extracted_at) as label,
        argMax(department_id,  _airbyte_extracted_at) as department_id,
        argMax(manager_id,     _airbyte_extracted_at) as manager_id,
        argMax(budget_year,    _airbyte_extracted_at) as budget_year,
        argMax(is_active,      _airbyte_extracted_at) as is_active,
        argMax(created_at,     _airbyte_extracted_at) as created_at,
        argMax(updated_at,     _airbyte_extracted_at) as updated_at,
        max(_airbyte_extracted_at)                    as latest_extracted_at
    from source
    group by id

)

select
    cast(id                               as varchar)   as id_cost_center,
    cast(coalesce(code, '')               as varchar)   as code,
    cast(coalesce(label, '')              as varchar)   as label,
    cast(coalesce(department_id, '')      as varchar)   as department_id,
    cast(coalesce(manager_id, '')         as varchar)   as manager_id,
    coalesce(budget_year, 0)                            as budget_year,
    cast(coalesce(is_active, false)       as boolean)   as is_active,
    cast(created_at                       as timestamp) as created_at,
    toDateTimeOrNull(toString(updated_at))              as updated_at,
    cast(latest_extracted_at              as timestamp) as _etl_loaded_at
from deduped
