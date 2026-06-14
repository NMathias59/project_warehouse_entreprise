{{ config(tags=['staging', 'sav']) }}

with source as (

    select * from {{ source('sav', 'customer_satisfaction') }}
    where id is not null

),

deduped as (

    select
        id,
        argMax(ticket_id,        _airbyte_extracted_at) as ticket_id,
        argMax(intervention_id,  _airbyte_extracted_at) as intervention_id,
        argMax(customer_id,      _airbyte_extracted_at) as customer_id,
        argMax(survey_type,      _airbyte_extracted_at) as survey_type,
        argMax(score,            _airbyte_extracted_at) as score,
        argMax(comment,          _airbyte_extracted_at) as comment,
        argMax(surveyed_at,      _airbyte_extracted_at) as surveyed_at,
        argMax(created_at,       _airbyte_extracted_at) as created_at,
        max(_airbyte_extracted_at)                      as latest_extracted_at
    from source
    group by id

)

select
    cast(id                                  as varchar)   as id_customer_satisfaction,
    cast(coalesce(ticket_id, '')             as varchar)   as ticket_id,
    cast(coalesce(intervention_id, '')       as varchar)   as intervention_id,
    cast(coalesce(customer_id, '')           as varchar)   as customer_id,
    cast(coalesce(survey_type, '')           as varchar)   as survey_type,
    coalesce(score, 0)                                     as score,
    cast(coalesce(comment, '')               as varchar)   as comment,
    cast(surveyed_at                         as timestamp) as surveyed_at,
    cast(created_at                          as timestamp) as created_at,
    cast(latest_extracted_at                 as timestamp) as _etl_loaded_at
from deduped
