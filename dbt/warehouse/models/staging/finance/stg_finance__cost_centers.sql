{{ config(tags=['staging', 'finance']) }}

select
    cast(id                                                                                as varchar)   as id_cost_center,
    cast(coalesce(argMax(code,           _airbyte_extracted_at), '')                       as varchar)   as code,
    cast(coalesce(argMax(name,           _airbyte_extracted_at), '')                       as varchar)   as label,
    cast(coalesce(argMax(department_ref, _airbyte_extracted_at), '')                       as varchar)   as department_id,
    cast(''                                                                                as varchar)   as manager_id,
    0                                                                                                    as budget_year,
    cast(coalesce(argMax(is_active,      _airbyte_extracted_at), false)                    as boolean)   as is_active,
    cast(null                                                                              as Nullable(DateTime64(3))) as created_at,
    cast(null                                                                              as Nullable(DateTime64(3))) as updated_at,
    cast(max(_airbyte_extracted_at)                                                        as timestamp) as _etl_loaded_at
from {{ source('finance', 'cost_centers') }}
where id is not null
group by id
