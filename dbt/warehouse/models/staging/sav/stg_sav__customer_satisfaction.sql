{{ config(tags=['staging', 'sav']) }}

with base as (

    select * from {{ ref('base_sav__customer_satisfaction') }}

)

select
    cast(id                                  as varchar)   as id_customer_satisfaction,
    cast(coalesce(ticket_id, '')             as varchar)   as ticket_id,
    cast(''                                  as varchar)   as intervention_id,
    cast(coalesce(customer_id, '')           as varchar)   as customer_id,
    cast(''                                  as varchar)   as survey_type,
    coalesce(score, 0)                                     as score,
    cast(coalesce(comment, '')               as varchar)   as comment,
    cast(surveyed_at                         as timestamp) as surveyed_at,
    cast(surveyed_at                         as timestamp) as created_at,
    cast(latest_extracted_at                as timestamp) as _etl_loaded_at
from base
