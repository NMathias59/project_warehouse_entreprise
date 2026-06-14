{{ config(tags=['staging', 'qms']) }}

with source as (

    select * from {{ source('qms', 'control_points') }}
    where id is not null

),

deduped as (

    select
        id,
        argMax(control_plan_id,         _airbyte_extracted_at) as control_plan_id,
        argMax(step_name,               _airbyte_extracted_at) as step_name,
        argMax(characteristic,          _airbyte_extracted_at) as characteristic,
        argMax(control_method,          _airbyte_extracted_at) as control_method,
        argMax(frequency,               _airbyte_extracted_at) as frequency,
        argMax(specification_min,       _airbyte_extracted_at) as specification_min,
        argMax(specification_max,       _airbyte_extracted_at) as specification_max,
        argMax(specification_nominal,   _airbyte_extracted_at) as specification_nominal,
        argMax(unit_of_measure,         _airbyte_extracted_at) as unit_of_measure,
        argMax(reaction_plan,           _airbyte_extracted_at) as reaction_plan,
        argMax(created_at,              _airbyte_extracted_at) as created_at,
        max(_airbyte_extracted_at)                             as latest_extracted_at
    from source
    group by id

)

select
    cast(id                                      as varchar)       as id_control_point,
    cast(coalesce(control_plan_id, '')           as varchar)       as control_plan_id,
    cast(coalesce(step_name, '')                 as varchar)       as step_name,
    cast(coalesce(characteristic, '')            as varchar)       as characteristic,
    cast(coalesce(control_method, '')            as varchar)       as control_method,
    cast(coalesce(frequency, '')                 as varchar)       as frequency,
    cast(coalesce(specification_min, 0)          as decimal(18,2)) as specification_min,
    cast(coalesce(specification_max, 0)          as decimal(18,2)) as specification_max,
    cast(coalesce(specification_nominal, 0)      as decimal(18,2)) as specification_nominal,
    cast(coalesce(unit_of_measure, '')           as varchar)       as unit_of_measure,
    cast(coalesce(reaction_plan, '')             as varchar)       as reaction_plan,
    cast(created_at                              as timestamp)     as created_at,
    cast(latest_extracted_at                     as timestamp)     as _etl_loaded_at
from deduped
