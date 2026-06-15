{{ config(materialized='view', tags=['staging', 'mes']) }}

select
    id,
    argMax(inspection_id,      _airbyte_extracted_at) as operation_id,
    argMax(defect_code,        _airbyte_extracted_at) as defect_code,
    argMax(description,        _airbyte_extracted_at) as defect_description,
    argMax(severity,           _airbyte_extracted_at) as severity,
    argMax(created_at,         _airbyte_extracted_at) as created_at,
    max(_airbyte_extracted_at)                    as latest_extracted_at
from {{ source('mes', 'defects') }}
where id is not null
group by id
