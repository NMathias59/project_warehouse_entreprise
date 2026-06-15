{{ config(tags=['staging', 'sav']) }}

with base as (

    select * from {{ ref('base_sav__interventions') }}

)

select
    cast(id                                    as varchar)       as id_intervention,
    cast(''                                    as varchar)       as reference,
    cast(''                                    as varchar)       as ticket_id,
    cast(coalesce(technician_id, '')           as varchar)       as technician_id,
    cast(''                                    as varchar)       as customer_id,
    cast(''                                    as varchar)       as product_id,
    cast(''                                    as varchar)       as intervention_type,
    cast(coalesce(status, '')                  as varchar)       as status,
    cast(coalesce(diagnostic, '')              as varchar)       as diagnostic,
    cast(coalesce(resolution, '')              as varchar)       as resolution,
    cast(null as Nullable(DateTime64(3)))                        as scheduled_at,
    toDateTimeOrNull(toString(started_at))                       as started_at,
    toDateTimeOrNull(toString(completed_at))                     as completed_at,
    cast(0                                     as decimal(18,2)) as travel_km,
    cast(coalesce(duration_minutes, 0)         as decimal(18,2)) as duration_minutes,
    cast(null as Nullable(DateTime64(3)))                        as created_at,
    cast(null as Nullable(DateTime64(3)))                        as updated_at,
    cast(latest_extracted_at                as timestamp)     as _etl_loaded_at
from base
