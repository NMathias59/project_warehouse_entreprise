{{ config(tags=['staging', 'sirh']) }}

with source as (

    select * from {{ source('sirh', 'training_sessions') }}
    where id is not null

),

deduped as (

    select
        id,
        argMax(title,            _airbyte_extracted_at) as title,
        argMax(training_type,    _airbyte_extracted_at) as training_type,
        argMax(provider,         _airbyte_extracted_at) as provider,
        argMax(duration_hours,   _airbyte_extracted_at) as duration_hours,
        argMax(cost_per_person,  _airbyte_extracted_at) as cost_per_person,
        argMax(planned_at,       _airbyte_extracted_at) as planned_at,
        argMax(completed_at,     _airbyte_extracted_at) as completed_at,
        argMax(is_mandatory,     _airbyte_extracted_at) as is_mandatory,
        argMax(created_at,       _airbyte_extracted_at) as created_at,
        argMax(updated_at,       _airbyte_extracted_at) as updated_at,
        max(_airbyte_extracted_at)                      as latest_extracted_at
    from source
    group by id

)

select
    cast(id                                  as varchar)       as id_training_session,
    cast(coalesce(title, '')                 as varchar)       as title,
    cast(coalesce(training_type, '')         as varchar)       as training_type,
    cast(coalesce(provider, '')              as varchar)       as provider,
    cast(coalesce(duration_hours, 0)         as decimal(18,2)) as duration_hours,
    cast(coalesce(cost_per_person, 0)        as decimal(18,2)) as cost_per_person,
    toDateTimeOrNull(toString(planned_at))                     as planned_at,
    toDateTimeOrNull(toString(completed_at))                   as completed_at,
    cast(coalesce(is_mandatory, false)       as boolean)       as is_mandatory,
    cast(created_at                          as timestamp)     as created_at,
    toDateTimeOrNull(toString(updated_at))                     as updated_at,
    cast(latest_extracted_at                 as timestamp)     as _etl_loaded_at
from deduped
