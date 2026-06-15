{{ config(tags=['staging', 'sirh']) }}

with source as (

    select * from {{ source('sirh', 'positions') }}
    where id is not null

),

deduped as (

    select
        id,
        argMax(title,         _airbyte_extracted_at) as title,
        argMax(department_id, _airbyte_extracted_at) as department_id,
        argMax(level,         _airbyte_extracted_at) as seniority_level,
        argMax(is_active,     _airbyte_extracted_at) as is_active,
        argMax(created_at,    _airbyte_extracted_at) as created_at,
        max(_airbyte_extracted_at)                   as latest_extracted_at
    from source
    group by id

)

select
    cast(id                               as varchar)   as id_position,
    cast(''                               as varchar)   as code,
    cast(coalesce(title, '')              as varchar)   as title,
    cast(coalesce(department_id, '')      as varchar)   as department_id,
    cast(''                               as varchar)   as job_family,
    cast(coalesce(seniority_level, '')    as varchar)   as seniority_level,
    cast(coalesce(is_active, false)       as boolean)   as is_active,
    cast(created_at                       as timestamp) as created_at,
    cast(null as Nullable(DateTime64(3))) as updated_at,
    cast(latest_extracted_at              as timestamp) as _etl_loaded_at
from deduped
