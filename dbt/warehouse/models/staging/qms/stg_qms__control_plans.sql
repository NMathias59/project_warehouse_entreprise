{{ config(tags=['staging', 'qms']) }}

select
    cast('' as varchar)              as id_control_plan,
    cast('' as varchar)              as product_id,
    cast('' as varchar)              as process_name,
    cast('' as varchar)              as version,
    cast('' as varchar)              as status,
    cast('' as varchar)              as responsible_id,
    cast(null as Nullable(Date32))   as effective_date,
    cast(null as Nullable(DateTime64(3))) as created_at,
    cast(null as Nullable(DateTime64(3))) as updated_at,
    cast(now() as timestamp)         as _etl_loaded_at
from {{ source('qms', 'control_plans') }}
where 1 = 0
