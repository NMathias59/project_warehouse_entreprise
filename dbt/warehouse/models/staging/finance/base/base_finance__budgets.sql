{{ config(materialized='view', tags=['staging', 'finance']) }}

select
    id,
    argMax(fiscal_year_id, _airbyte_extracted_at) as fiscal_year_id,
    max(_airbyte_extracted_at)                    as latest_extracted_at
from {{ source('finance', 'budgets') }}
where id is not null
group by id
