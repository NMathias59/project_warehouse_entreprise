{{ config(tags=['staging', 'mes']) }}

select
    cast('' as varchar)              as id_shift,
    cast('' as varchar)              as name,
    cast('' as varchar)              as start_time,
    cast('' as varchar)              as end_time,
    cast(false as boolean)           as is_night_shift,
    cast(false as boolean)           as is_active,
    cast(null as Nullable(DateTime64(3))) as created_at,
    cast(now() as timestamp)         as _etl_loaded_at
from {{ source('mes', 'shifts') }}
where 1 = 0
