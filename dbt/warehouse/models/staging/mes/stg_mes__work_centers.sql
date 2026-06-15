{{ config(tags=['staging', 'mes']) }}

with base as (

    select * from {{ ref('base_mes__work_centers') }}

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
    cast(latest_extracted_at                as timestamp)     as _etl_loaded_at
from base
