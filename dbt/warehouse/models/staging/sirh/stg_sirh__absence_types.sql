{{ config(tags=['staging', 'sirh']) }}

select
    cast('' as varchar)              as id_absence_type,
    cast('' as varchar)              as code,
    cast('' as varchar)              as label,
    cast(false as boolean)           as is_paid,
    cast(false as boolean)           as requires_approval,
    cast(false as boolean)           as is_active,
    cast(null as Nullable(DateTime64(3))) as created_at,
    cast(now() as timestamp)         as _etl_loaded_at
from {{ source('sirh', 'absence_types') }}
where 1 = 0
