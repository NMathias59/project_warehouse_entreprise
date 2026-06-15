{{ config(tags=['staging', 'marketing']) }}

with base as (

    select * from {{ ref('base_marketing__audiences') }}

)

select
    cast(id                               as varchar)   as id_audience,
    cast(coalesce(name, '')               as varchar)   as name,
    cast(coalesce(description, '')        as varchar)   as description,
    cast(coalesce(segment_type, '')       as varchar)   as segment_type,
    cast(coalesce(criteria, '')           as varchar)   as criteria,
    coalesce(estimated_size, 0)                         as estimated_size,
    cast(coalesce(is_active, false)       as boolean)   as is_active,
    cast(created_at                       as timestamp) as created_at,
    cast(null as Nullable(DateTime64(3)))               as updated_at,
    cast(latest_extracted_at                as timestamp) as _etl_loaded_at
from base
