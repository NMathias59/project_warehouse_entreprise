{{ config(tags=['staging', 'finance']) }}

with source as (

    select * from {{ source('finance', 'bank_transactions') }}
    where id is not null

),

deduped as (

    select
        id,
        argMax(bank_account_id,    _airbyte_extracted_at) as bank_account_id,
        argMax(transaction_date,   _airbyte_extracted_at) as transaction_date,
        argMax(value_date,         _airbyte_extracted_at) as value_date,
        argMax(transaction_type,   _airbyte_extracted_at) as transaction_type,
        argMax(description,        _airbyte_extracted_at) as description,
        argMax(amount,             _airbyte_extracted_at) as amount,
        argMax(currency,           _airbyte_extracted_at) as currency,
        argMax(reference,          _airbyte_extracted_at) as reference,
        argMax(is_reconciled,      _airbyte_extracted_at) as is_reconciled,
        argMax(journal_line_id,    _airbyte_extracted_at) as journal_line_id,
        argMax(created_at,         _airbyte_extracted_at) as created_at,
        max(_airbyte_extracted_at)                        as latest_extracted_at
    from source
    group by id

)

select
    cast(id                                   as varchar)       as id_bank_transaction,
    cast(coalesce(bank_account_id, '')        as varchar)       as bank_account_id,
    cast(transaction_date                     as date)          as transaction_date,
    cast(value_date                           as date)          as value_date,
    cast(coalesce(transaction_type, '')       as varchar)       as transaction_type,
    cast(coalesce(description, '')            as varchar)       as description,
    cast(coalesce(amount, 0)                  as decimal(18,2)) as amount,
    cast(coalesce(currency, '')               as varchar)       as currency,
    cast(coalesce(reference, '')              as varchar)       as reference,
    cast(coalesce(is_reconciled, false)       as boolean)       as is_reconciled,
    cast(coalesce(journal_line_id, '')        as varchar)       as journal_line_id,
    cast(created_at                           as timestamp)     as created_at,
    cast(latest_extracted_at                  as timestamp)     as _etl_loaded_at
from deduped
