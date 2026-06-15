{{ config(tags=['staging', 'finance']) }}

with base as (

    select * from {{ ref('base_finance__cost_centers') }}

)

select
    cast(id                                    as varchar)   as id_cost_center,
    cast(coalesce(code,           '')          as varchar)   as code,
    cast(coalesce(name,           '')          as varchar)   as label,
    cast(coalesce(department_ref, '')          as varchar)   as department_id,
    cast(''                                    as varchar)   as manager_id,
    0                                                        as budget_year,
    cast(coalesce(is_active,      false)       as boolean)   as is_active,
    cast(null as Nullable(DateTime64(3)))                    as created_at,
    cast(null as Nullable(DateTime64(3)))                    as updated_at,
    cast(latest_extracted_at                as timestamp) as _etl_loaded_at
from base
