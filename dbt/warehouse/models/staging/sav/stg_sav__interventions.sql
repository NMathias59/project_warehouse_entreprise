{{ config(tags=['staging', 'sav']) }}

with source as (

    select * from {{ source('sav', 'interventions') }}
    where id is not null

),

deduped as (

    select
        id,
        argMax(reference,           _airbyte_extracted_at) as reference,
        argMax(ticket_id,           _airbyte_extracted_at) as ticket_id,
        argMax(technician_id,       _airbyte_extracted_at) as technician_id,
        argMax(customer_id,         _airbyte_extracted_at) as customer_id,
        argMax(product_id,          _airbyte_extracted_at) as product_id,
        argMax(intervention_type,   _airbyte_extracted_at) as intervention_type,
        argMax(status,              _airbyte_extracted_at) as status,
        argMax(diagnostic,          _airbyte_extracted_at) as diagnostic,
        argMax(resolution,          _airbyte_extracted_at) as resolution,
        argMax(scheduled_at,        _airbyte_extracted_at) as scheduled_at,
        argMax(started_at,          _airbyte_extracted_at) as started_at,
        argMax(completed_at,        _airbyte_extracted_at) as completed_at,
        argMax(travel_km,           _airbyte_extracted_at) as travel_km,
        argMax(duration_minutes,    _airbyte_extracted_at) as duration_minutes,
        argMax(created_at,          _airbyte_extracted_at) as created_at,
        argMax(updated_at,          _airbyte_extracted_at) as updated_at,
        max(_airbyte_extracted_at)                         as latest_extracted_at
    from source
    group by id

)

select
    cast(id                                    as varchar)       as id_intervention,
    cast(coalesce(reference, '')               as varchar)       as reference,
    cast(coalesce(ticket_id, '')               as varchar)       as ticket_id,
    cast(coalesce(technician_id, '')           as varchar)       as technician_id,
    cast(coalesce(customer_id, '')             as varchar)       as customer_id,
    cast(coalesce(product_id, '')              as varchar)       as product_id,
    cast(coalesce(intervention_type, '')       as varchar)       as intervention_type,
    cast(coalesce(status, '')                  as varchar)       as status,
    cast(coalesce(diagnostic, '')              as varchar)       as diagnostic,
    cast(coalesce(resolution, '')              as varchar)       as resolution,
    toDateTimeOrNull(toString(scheduled_at))                     as scheduled_at,
    toDateTimeOrNull(toString(started_at))                       as started_at,
    toDateTimeOrNull(toString(completed_at))                     as completed_at,
    cast(coalesce(travel_km, 0)                as decimal(18,2)) as travel_km,
    cast(coalesce(duration_minutes, 0)         as decimal(18,2)) as duration_minutes,
    cast(created_at                            as timestamp)     as created_at,
    toDateTimeOrNull(toString(updated_at))                       as updated_at,
    cast(latest_extracted_at                   as timestamp)     as _etl_loaded_at
from deduped
