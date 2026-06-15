{{ config(materialized='view', tags=['staging', 'wms']) }}

select
    id,
    argMax(transfer_number,  _airbyte_extracted_at) as transfer_number,
    argMax(status,           _airbyte_extracted_at) as status,
    argMax(completed_at,     _airbyte_extracted_at) as completed_at,
    argMax(created_at,       _airbyte_extracted_at) as created_at,
    max(_airbyte_extracted_at)                    as latest_extracted_at
from {{ source('wms', 'shipments') }}
where id is not null
group by id
