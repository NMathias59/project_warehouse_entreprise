{{ config(materialized='view', tags=['staging', 'plm']) }}

select
    id,
    argMax(bom_id,         _airbyte_extracted_at) as bom_id,
    argMax(component_sku,  _airbyte_extracted_at) as component_code,
    argMax(component_name, _airbyte_extracted_at) as component_name,
    argMax(quantity,       _airbyte_extracted_at) as quantity,
    argMax(unit,           _airbyte_extracted_at) as unit_of_measure,
    max(_airbyte_extracted_at)                    as latest_extracted_at
from {{ source('plm', 'bom_lines') }}
where id is not null
group by id
