{{ config(materialized='view', tags=['staging', 'finance']) }}

select
    id,
    argMax(bank_account_id,   _airbyte_extracted_at) as bank_account_id,
    argMax(transaction_date,  _airbyte_extracted_at) as transaction_date,
    argMax(value_date,        _airbyte_extracted_at) as value_date,
    argMax(direction,         _airbyte_extracted_at) as direction,
    argMax(description,       _airbyte_extracted_at) as description,
    argMax(amount_eur,        _airbyte_extracted_at) as amount_eur,
    argMax(reference,         _airbyte_extracted_at) as reference,
    argMax(reconciled,        _airbyte_extracted_at) as reconciled,
    argMax(journal_entry_id,  _airbyte_extracted_at) as journal_entry_id,
    argMax(created_at,        _airbyte_extracted_at) as created_at,
    max(_airbyte_extracted_at)                    as latest_extracted_at
from {{ source('finance', 'bank_transactions') }}
where id is not null
group by id
