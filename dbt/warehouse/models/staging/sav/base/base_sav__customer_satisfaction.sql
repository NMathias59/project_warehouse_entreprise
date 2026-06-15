{{ config(materialized='view', tags=['staging', 'sav']) }}

select
    id,
    argMax(ticket_id,     _airbyte_extracted_at) as ticket_id,
    argMax(customer_ref,  _airbyte_extracted_at) as customer_id,
    argMax(csat_score,    _airbyte_extracted_at) as score,
    argMax(comment,       _airbyte_extracted_at) as comment,
    argMax(submitted_at,  _airbyte_extracted_at) as surveyed_at,
    max(_airbyte_extracted_at)                    as latest_extracted_at
from {{ source('sav', 'customer_satisfaction') }}
where id is not null
group by id
