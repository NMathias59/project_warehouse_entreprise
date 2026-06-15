{{ config(tags=['staging', 'mes']) }}

with source as (

    select * from {{ source('mes', 'work_centers') }}
    where id is not null

),

deduped as (

    select
        id,
        argMax(code,               _airbyte_extracted_at) as code,
        argMax(name,               _airbyte_extracted_at) as name,
        argMax(center_type,        _airbyte_extracted_at) as work_center_type,
        argMax(capacity_per_shift, _airbyte_extracted_at) as capacity_per_hour,
        argMax(is_active,          _airbyte_extracted_at) as is_active,
        argMax(created_at,         _airbyte_extracted_at) as created_at,
        max(_airbyte_extracted_at)                        as latest_extracted_at
    from source
    group by id

)

select
    cast(id                                   as varchar)       as id_work_center,
    cast(coalesce(code, '')                   as varchar)       as code,
    cast(coalesce(name, '')                   as varchar)       as name,
    cast(''                                   as varchar)       as department_id,
    cast(coalesce(work_center_type, '')       as varchar)       as work_center_type,
    cast(coalesce(capacity_per_hour, 0)       as decimal(18,2)) as capacity_per_hour,
    cast(coalesce(is_active, false)           as boolean)       as is_active,
    cast(created_at                           as timestamp)     as created_at,
    cast(null as Nullable(DateTime64(3)))                       as updated_at,
    cast(latest_extracted_at                  as timestamp)     as _etl_loaded_at
from deduped
