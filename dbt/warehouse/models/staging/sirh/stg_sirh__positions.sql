{{ config(tags=['staging', 'sirh']) }}

with base as (

    select * from {{ ref('base_sirh__positions') }}

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
    cast(latest_extracted_at                as timestamp) as _etl_loaded_at
from base
