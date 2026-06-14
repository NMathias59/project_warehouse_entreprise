{{ config(tags=['staging', 'marketing']) }}

with source as (

    select * from {{ source('marketing', 'audiences') }}
    where id is not null

),

deduped as (

    select
        id,
        argMax(name,            _airbyte_extracted_at) as name,
        argMax(description,     _airbyte_extracted_at) as description,
        argMax(segment_type,    _airbyte_extracted_at) as segment_type,
        argMax(criteria,        _airbyte_extracted_at) as criteria,
        argMax(estimated_size,  _airbyte_extracted_at) as estimated_size,
        argMax(is_active,       _airbyte_extracted_at) as is_active,
        argMax(created_at,      _airbyte_extracted_at) as created_at,
        argMax(updated_at,      _airbyte_extracted_at) as updated_at,
        max(_airbyte_extracted_at)                     as latest_extracted_at
    from source
    group by id

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
    toDateTimeOrNull(toString(updated_at))              as updated_at,
    cast(latest_extracted_at              as timestamp) as _etl_loaded_at
from deduped
