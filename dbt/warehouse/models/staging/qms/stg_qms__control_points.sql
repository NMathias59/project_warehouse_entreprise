{{ config(tags=['staging', 'qms']) }}

select
    cast('' as varchar)              as id_control_point,
    cast('' as varchar)              as control_plan_id,
    cast('' as varchar)              as step_name,
    cast('' as varchar)              as characteristic,
    cast('' as varchar)              as control_method,
    cast('' as varchar)              as frequency,
    cast(0 as decimal(18,2))         as specification_min,
    cast(0 as decimal(18,2))         as specification_max,
    cast(0 as decimal(18,2))         as specification_nominal,
    cast('' as varchar)              as unit_of_measure,
    cast('' as varchar)              as reaction_plan,
    cast(null as Nullable(DateTime64(3))) as created_at,
    cast(now() as timestamp)         as _etl_loaded_at
from {{ source('qms', 'control_points') }}
where 1 = 0
