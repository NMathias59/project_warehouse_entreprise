{{ config(materialized='view', tags=['staging', 'qms']) }}

select
    id,
    argMax(nc_number,    _airbyte_extracted_at) as reference,
    argMax(description,  _airbyte_extracted_at) as description,
    argMax(`source`,     _airbyte_extracted_at) as nc_type,
    argMax(severity,     _airbyte_extracted_at) as severity,
    argMax(product_sku,  _airbyte_extracted_at) as product_id,
    argMax(status,       _airbyte_extracted_at) as status,
    argMax(detected_at,  _airbyte_extracted_at) as detected_at,
    argMax(closed_at,    _airbyte_extracted_at) as closed_at,
    max(_airbyte_extracted_at)                    as latest_extracted_at
from {{ source('qms', 'non_conformities') }}
where id is not null
group by id
