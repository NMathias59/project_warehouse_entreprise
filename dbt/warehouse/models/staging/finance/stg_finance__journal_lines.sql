{{ config(tags=['staging', 'finance']) }}

with source as (

    select * from {{ source('finance', 'journal_lines') }}
    where id is not null

),

deduped as (

    select
        id,
        argMax(journal_entry_id,  _airbyte_extracted_at) as journal_entry_id,
        argMax(line_number,       _airbyte_extracted_at) as line_number,
        argMax(account_id,        _airbyte_extracted_at) as account_id,
        argMax(cost_center_id,    _airbyte_extracted_at) as cost_center_id,
        argMax(description,       _airbyte_extracted_at) as description,
        argMax(debit_amount,      _airbyte_extracted_at) as debit_amount,
        argMax(credit_amount,     _airbyte_extracted_at) as credit_amount,
        argMax(currency,          _airbyte_extracted_at) as currency,
        argMax(exchange_rate,     _airbyte_extracted_at) as exchange_rate,
        argMax(created_at,        _airbyte_extracted_at) as created_at,
        max(_airbyte_extracted_at)                       as latest_extracted_at
    from source
    group by id

)

select
    cast(id                                  as varchar)       as id_journal_line,
    cast(coalesce(journal_entry_id, '')      as varchar)       as journal_entry_id,
    coalesce(line_number, 0)                                   as line_number,
    cast(coalesce(account_id, '')            as varchar)       as account_id,
    cast(coalesce(cost_center_id, '')        as varchar)       as cost_center_id,
    cast(coalesce(description, '')           as varchar)       as description,
    cast(coalesce(debit_amount, 0)           as decimal(18,2)) as debit_amount,
    cast(coalesce(credit_amount, 0)          as decimal(18,2)) as credit_amount,
    cast(coalesce(currency, '')              as varchar)       as currency,
    cast(coalesce(exchange_rate, 0)          as decimal(18,6)) as exchange_rate,
    cast(created_at                          as timestamp)     as created_at,
    cast(latest_extracted_at                 as timestamp)     as _etl_loaded_at
from deduped
