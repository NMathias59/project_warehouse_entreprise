{{ config(materialized='view', tags=['staging', 'finance']) }}

select
    id,
    argMax(entry_id,       _airbyte_extracted_at) as entry_id,
    argMax(account_id,     _airbyte_extracted_at) as account_id,
    argMax(cost_center_id, _airbyte_extracted_at) as cost_center_id,
    argMax(description,    _airbyte_extracted_at) as description,
    argMax(debit_eur,      _airbyte_extracted_at) as debit_eur,
    argMax(credit_eur,     _airbyte_extracted_at) as credit_eur,
    max(_airbyte_extracted_at)                    as latest_extracted_at
from {{ source('finance', 'journal_lines') }}
where id is not null
group by id
