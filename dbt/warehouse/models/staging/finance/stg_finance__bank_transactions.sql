{{ config(tags=['staging', 'finance']) }}

select
    cast(id                                                                                  as varchar)       as id_bank_transaction,
    cast(coalesce(argMax(bank_account_id,   _airbyte_extracted_at), '')                      as varchar)       as bank_account_id,
    cast(argMax(transaction_date,           _airbyte_extracted_at)                           as date)          as transaction_date,
    cast(argMax(value_date,                 _airbyte_extracted_at)                           as Nullable(Date)) as value_date,
    cast(coalesce(argMax(direction,         _airbyte_extracted_at), '')                      as varchar)       as transaction_type,
    cast(coalesce(argMax(description,       _airbyte_extracted_at), '')                      as varchar)       as description,
    cast(coalesce(argMax(amount_eur,        _airbyte_extracted_at), 0)                       as decimal(18,2)) as amount,
    cast(''                                                                                  as varchar)       as currency,
    cast(coalesce(argMax(reference,         _airbyte_extracted_at), '')                      as varchar)       as reference,
    cast(coalesce(argMax(reconciled,        _airbyte_extracted_at), false)                   as boolean)       as is_reconciled,
    cast(coalesce(argMax(journal_entry_id,  _airbyte_extracted_at), '')                      as varchar)       as journal_line_id,
    cast(argMax(created_at,                 _airbyte_extracted_at)                           as timestamp)     as created_at,
    cast(max(_airbyte_extracted_at)                                                          as timestamp)     as _etl_loaded_at
from {{ source('finance', 'bank_transactions') }}
where id is not null
group by id
