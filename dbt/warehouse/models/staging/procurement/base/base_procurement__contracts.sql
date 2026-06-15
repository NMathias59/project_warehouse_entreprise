{{ config(materialized='view', tags=['staging', 'procurement']) }}

select
    id,
    argMax(contract_number, _airbyte_extracted_at) as reference,
    argMax(supplier_id,     _airbyte_extracted_at) as supplier_id,
    argMax(contract_type,   _airbyte_extracted_at) as contract_type,
    argMax(status,          _airbyte_extracted_at) as status,
    argMax(title,           _airbyte_extracted_at) as title,
    argMax(value_eur,       _airbyte_extracted_at) as total_amount,
    argMax(start_date,      _airbyte_extracted_at) as start_date,
    argMax(end_date,        _airbyte_extracted_at) as end_date,
    argMax(created_at,      _airbyte_extracted_at) as created_at,
    max(_airbyte_extracted_at)                    as latest_extracted_at
from {{ source('procurement', 'contracts') }}
where id is not null
group by id
