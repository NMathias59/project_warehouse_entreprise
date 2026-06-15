{{ config(tags=['staging', 'sirh']) }}

with base as (

    select * from {{ ref('base_sirh__training_sessions') }}

)

select
    cast(id                                  as varchar)       as id_training_session,
    cast(coalesce(title, '')                 as varchar)       as title,
    cast(coalesce(training_type, '')         as varchar)       as training_type,
    cast(coalesce(provider, '')              as varchar)       as provider,
    cast(coalesce(duration_hours, 0)         as decimal(18,2)) as duration_hours,
    cast(coalesce(cost_per_person, 0)        as decimal(18,2)) as cost_per_person,
    cast(null as Nullable(DateTime64(3)))                      as planned_at,
    cast(null as Nullable(DateTime64(3)))                      as completed_at,
    cast(coalesce(is_mandatory, false)       as boolean)       as is_mandatory,
    cast(created_at                          as timestamp)     as created_at,
    cast(null as Nullable(DateTime64(3)))                      as updated_at,
    cast(latest_extracted_at                as timestamp)     as _etl_loaded_at
from base
