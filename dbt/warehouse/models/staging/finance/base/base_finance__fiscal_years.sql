{{ config(materialized='view', tags=['staging', 'finance']) }}

select
    id,
    argMax(year,       _airbyte_extracted_at) as year,
    argMax(start_date, _airbyte_extracted_at) as start_date,
    argMax(end_date,   _airbyte_extracted_at) as end_date,
    argMax(status,     _airbyte_extracted_at) as status,
    argMax(closed_at,  _airbyte_extracted_at) as closed_at,
    max(_airbyte_extracted_at)                    as latest_extracted_at
from {{ source('finance', 'fiscal_years') }}
where id is not null
group by id
