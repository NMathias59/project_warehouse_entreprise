{{ config(materialized='view', tags=['staging', 'procurement']) }}

select
    id,
    argMax(rfq_number,     _airbyte_extracted_at) as reference,
    argMax(status,         _airbyte_extracted_at) as status,
    argMax(requester_ref,  _airbyte_extracted_at) as buyer_id,
    argMax(deadline,       _airbyte_extracted_at) as delivery_date_requested,
    argMax(description,    _airbyte_extracted_at) as description,
    argMax(created_at,     _airbyte_extracted_at) as created_at,
    max(_airbyte_extracted_at)                    as latest_extracted_at
from {{ source('procurement', 'rfqs') }}
where id is not null
group by id
