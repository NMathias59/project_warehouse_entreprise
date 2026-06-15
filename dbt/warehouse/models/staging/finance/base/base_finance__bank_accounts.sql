{{ config(materialized='view', tags=['staging', 'finance']) }}

select
    id,
    argMax(iban,      _airbyte_extracted_at) as iban,
    argMax(bic,       _airbyte_extracted_at) as bic,
    argMax(bank_name, _airbyte_extracted_at) as bank_name,
    argMax(currency,  _airbyte_extracted_at) as currency,
    argMax(is_active, _airbyte_extracted_at) as is_active,
    max(_airbyte_extracted_at)                    as latest_extracted_at
from {{ source('finance', 'bank_accounts') }}
where id is not null
group by id
